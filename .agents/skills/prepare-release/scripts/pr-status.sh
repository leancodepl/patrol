#!/usr/bin/env bash
# Open PRs on leancodepl/patrol, bucketed by how close they are to merging:
# ready / near / work / far. Failing checks known to be noise (see
# references/ci-noise.md) are split from real failures. The buckets are a first
# pass; read the threads of anything you report as ready or near.
#
# Read-only. Uses paged GraphQL queries: `gh pr list` with statusCheckRollup,
# or a single page of every PR, times out on this repo. Needs an authenticated
# gh and jq.
#
# Usage: pr-status.sh          text report
#        pr-status.sh --json   one JSON object per PR, for further filtering
set -euo pipefail

query='query($owner: String!, $name: String!, $after: String) {
  rateLimit { cost remaining resetAt }
  repository(owner: $owner, name: $name) {
    pullRequests(states: OPEN, first: 15, after: $after, orderBy: {field: UPDATED_AT, direction: DESC}) {
      pageInfo { hasNextPage endCursor }
      nodes {
        number title isDraft mergeable reviewDecision additions deletions
        headRefName headRefOid isCrossRepository author { login }
        files(first: 100) { nodes { path } }
        latestReviews(first: 20) { nodes { author { login } state submittedAt commit { oid } } }
        reviewThreads(first: 60) {
          pageInfo { hasNextPage }
          nodes {
            isResolved path
            opener: comments(first: 1) { nodes { author { login } body } }
            latest: comments(last: 1) { nodes { author { login } createdAt } }
          }
        }
        commits(last: 1) {
          nodes {
            commit {
              committedDate
              statusCheckRollup {
                contexts(first: 100) {
                  nodes {
                    __typename
                    ... on CheckRun { name conclusion status }
                    ... on StatusContext { context state }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}'

classify='
def bot: test("\\[bot\\]$|^copilot-pull-request-reviewer$|^gemini-code-assist$|^github-actions$");
# Keep in sync with references/ci-noise.md.
def noise($fork; $release):
  test("^pana ")
  or (($release | not) and test("^Check semver"))
  or ($fork and test(" on API [0-9]+$|webview on emulator\\.wtf$"));

.[]
| (.author.login // "ghost") as $me
| .headRefOid as $head
| .commits.nodes[0].commit as $c
| $c.committedDate as $pushed
| .isCrossRepository as $fork
| (.headRefName | startswith("release/")) as $release
| [ ($c.statusCheckRollup.contexts.nodes // [])[]
    | if .__typename == "CheckRun"
      then {name, bad: (.conclusion | IN("FAILURE", "TIMED_OUT", "STARTUP_FAILURE", "ACTION_REQUIRED")),
            pending: (.status != "COMPLETED")}
      else {name: .context, bad: (.state | IN("FAILURE", "ERROR")), pending: (.state | IN("PENDING", "EXPECTED"))}
      end ] as $checks
| ([ $checks[] | select(.bad) | .name ] | unique) as $failing
| [ $failing[] | select(noise($fork; $release) | not) ] as $real
| [ $failing[] | select(noise($fork; $release)) ] as $noise
| ([ $checks[] | select(.pending) ] | length) as $pending
| [ .reviewThreads.nodes[] | select(.isResolved | not)
    | {path,
       opener: (.opener.nodes[0].author.login // "ghost"),
       body: ((.opener.nodes[0].body // "") | gsub("\\s+"; " ") | .[0:110]),
       last: (.latest.nodes[0].author.login // "ghost"),
       lastAt: .latest.nodes[0].createdAt} ] as $open
| [ $open[] | select(.opener | bot | not) ] as $human
| ([ $open[] | select(.opener | bot) ] | length) as $botThreads
| .reviewThreads.pageInfo.hasNextPage as $moreThreads
| [ .latestReviews.nodes[] | select((.author.login // "ghost") | (bot or . == $me) | not) ] as $reviews
| [ $reviews[] | select(.state == "APPROVED") ] as $approvals
| ([ $approvals[].submittedAt ] | max) as $approvedAt
| (($approvals | length) > 0 and all($approvals[]; .commit.oid != $head)) as $staleApproval
# A reviewer spoke after the last push and the author has not answered since.
# GitHub exposes no push time (Commit.pushedDate is null), so the date of the
# head commit stands in: a commit made before the review and pushed after it
# still counts as waiting. That can only move a PR to `work`, never to `ready`.
| ([ $human[] | select(.last != $me) | .lastAt ] | max) as $askedAt
| ($askedAt != null and $askedAt > $pushed) as $waiting
| ([ .files.nodes[].path | capture("^packages/(?<p>[^/]+)/").p ] | unique) as $packages
| ([ .files.nodes[].path | select(startswith("packages/") | not) | split("/")[0] ] | unique) as $other
| {number, title, author: $me, draft: .isDraft, fork: $fork, mergeable, review: (.reviewDecision // "NONE"),
   size: (.additions + .deletions), additions, deletions, pushed: $pushed,
   approvedAt: $approvedAt, approvalPredatesPush: $staleApproval,
   waitingOnAuthor: $waiting, realFailures: $real, noiseFailures: $noise, pending: $pending,
   humanThreads: $human, botThreads: $botThreads, moreThreads: $moreThreads,
   packages: $packages, otherPaths: $other,
   reviewers: [ $reviews[] | "\(.author.login):\(.state)@\(.submittedAt[5:10])" ]}
| .bucket = (
    if .draft then "far"
    elif .mergeable == "CONFLICTING" or .review == "CHANGES_REQUESTED" or .waitingOnAuthor
      or (.realFailures | length) > 0 then "work"
    elif .review == "APPROVED" and (.humanThreads | length) == 0 and .botThreads == 0
      and (.moreThreads | not) then "ready"
    elif .review == "APPROVED" or .size <= 400 then "near"
    else "far" end)'

fetch_page() {
  local attempt
  for attempt in 1 2 3; do
    gh api graphql -f owner=leancodepl -f name=patrol ${1:+-f after="$1"} -f query="$query" && return
    echo "page request failed (attempt $attempt), retrying" >&2
  done
  return 1
}

nodes='[]'
cost=0
cursor=''
while :; do
  page="$(fetch_page "$cursor")"
  nodes="$(jq -c --argjson acc "$nodes" '$acc + .data.repository.pullRequests.nodes' <<< "$page")"
  cost=$((cost + $(jq '.data.rateLimit.cost' <<< "$page")))
  [ "$(jq '.data.repository.pullRequests.pageInfo.hasNextPage' <<< "$page")" = true ] || break
  cursor="$(jq -r '.data.repository.pullRequests.pageInfo.endCursor' <<< "$page")"
done

prs="$(jq -c "$classify" <<< "$nodes")"

if [ "${1:-}" = "--json" ]; then
  echo "$prs"
  exit 0
fi

jq -r --slurp '
  def flags: [
    (if .draft then "draft" else empty end),
    (if .fork then "fork" else empty end),
    (if .mergeable == "CONFLICTING" then "conflicts with base"
     elif .mergeable == "UNKNOWN" then "mergeability not computed yet" else empty end),
    (if .waitingOnAuthor then "waiting on author" else empty end),
    (if .approvalPredatesPush then "approval predates last push" else empty end),
    (if .moreThreads then "over 60 review threads, only the first 60 counted" else empty end),
    (if .pending > 0 then "\(.pending) checks pending" else empty end) ];
  def where: (.packages + (.otherPaths | map("+" + .))) | join(",");
  group_by(.bucket) | map({key: .[0].bucket, value: .}) | from_entries as $b
  | ["ready", "near", "work", "far"][] as $k
  | select($b[$k])
  | "## \($k) (\($b[$k] | length))",
    ($b[$k][]
     | "#\(.number)\(if .draft then " [draft]" else "" end) @\(.author) · +\(.additions)/-\(.deletions) · \(.review) · \(if (.realFailures | length) > 0 then "CI FAILING" else "CI ok" end) · threads \(.humanThreads | length)+\(.botThreads)bot · \(where) — \(.title)",
       (select($k != "far")
        | (flags | select(length > 0) | "    " + join(" · ")),
          (.realFailures | select(length > 0) | "    failing: " + join(", ")),
          (.noiseFailures | select(length > 0) | "    noise: " + join(", ")),
          (.humanThreads[0:3][] | "    thread [\(.path)] @\(.opener): \(.body) (last @\(.last) \(.lastAt[5:10]))"),
          (.reviewers | select(length > 0) | "    reviews: " + join(", ")))),
    ""' <<< "$prs"

jq -r --arg cost "$cost" \
  '"GraphQL cost \($cost), \(.data.rateLimit.remaining) points left (resets \(.data.rateLimit.resetAt))"' <<< "$page"

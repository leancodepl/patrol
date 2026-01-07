"use client"

import { XEmbed, YouTubeEmbed } from "react-social-media-embed"
import { useTheme } from "next-themes"

export function YouTube({ id }: { id: string }) {
  return (
    <div className="[&_iframe]:max-w-full">
      <YouTubeEmbed url={`https://www.youtube.com/watch?v=${id}`} />
    </div>
  )
}
export function Tweet({ id }: { id: string }) {
  const { theme } = useTheme()

  return (
    <div className="[&_iframe]:rounded-[14px]">
      <XEmbed
        // key is needed to force re-render when theme changes
        key={theme}
        url={`https://x.com/${id}`}
        twitterTweetEmbedProps={{ tweetId: id, options: { theme } }}
      />
    </div>
  )
}

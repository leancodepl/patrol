using Patrol.WindowsRunner.Protocol;

namespace Patrol.WindowsRunner;

internal static class DartTestTree
{
    /// <summary>
    /// Flattens the Dart test tree the same way Android's listTestsFlat does:
    /// parent group names are space-concatenated into the leaf test name.
    /// </summary>
    public static IReadOnlyList<(string Name, bool Skip)> Flatten(DartGroupEntry root)
    {
        var results = new List<(string Name, bool Skip)>();
        Walk(root, parentGroupName: "", results);
        return results;
    }

    private static void Walk(
        DartGroupEntry node,
        string parentGroupName,
        List<(string Name, bool Skip)> results
    )
    {
        foreach (var entry in node.Entries)
        {
            if (entry.Type == "test")
            {
                if (string.IsNullOrEmpty(parentGroupName))
                {
                    throw new InvalidOperationException(
                        $"Invariant violated: test '{entry.Name}' has no named parent group"
                    );
                }

                results.Add(($"{parentGroupName} {entry.Name}", entry.Skip));
            }
            else if (entry.Type == "group")
            {
                var nextParent = string.IsNullOrEmpty(parentGroupName)
                    ? entry.Name
                    : $"{parentGroupName} {entry.Name}";
                Walk(entry, nextParent, results);
            }
        }
    }
}

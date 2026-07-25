using System.Text.Json.Serialization;

namespace Patrol.WindowsRunner.Protocol;

internal sealed class TapAtRequest
{
    [JsonPropertyName("x")]
    public double X { get; set; }

    [JsonPropertyName("y")]
    public double Y { get; set; }
}

internal sealed class RunDartTestRequest
{
    [JsonPropertyName("name")]
    public string Name { get; set; } = "";
}

internal sealed class RunDartTestResponse
{
    [JsonPropertyName("result")]
    public string Result { get; set; } = "";

    [JsonPropertyName("details")]
    public string? Details { get; set; }

    public bool Passed =>
        string.Equals(Result, "success", StringComparison.OrdinalIgnoreCase);
}

internal sealed class ListDartTestsResponse
{
    [JsonPropertyName("group")]
    public DartGroupEntry Group { get; set; } = new();
}

internal sealed class DartGroupEntry
{
    [JsonPropertyName("name")]
    public string Name { get; set; } = "";

    [JsonPropertyName("type")]
    public string Type { get; set; } = "";

    [JsonPropertyName("entries")]
    public List<DartGroupEntry> Entries { get; set; } = [];

    [JsonPropertyName("skip")]
    public bool Skip { get; set; }

    [JsonPropertyName("tags")]
    public List<string> Tags { get; set; } = [];
}

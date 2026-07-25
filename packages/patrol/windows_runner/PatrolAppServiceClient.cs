using System.Text;
using System.Text.Json;
using Patrol.WindowsRunner.Protocol;

namespace Patrol.WindowsRunner;

internal sealed class PatrolAppServiceClient
{
    private readonly HttpClient _http;
    private readonly JsonSerializerOptions _json = new()
    {
        PropertyNameCaseInsensitive = true,
    };

    public PatrolAppServiceClient(int appPort)
    {
        _http = new HttpClient
        {
            BaseAddress = new Uri($"http://127.0.0.1:{appPort}/"),
            Timeout = TimeSpan.FromMinutes(10),
        };
    }

    public async Task<ListDartTestsResponse> ListDartTestsAsync(CancellationToken ct)
    {
        using var response = await _http.PostAsync(
            "listDartTests",
            new StringContent("{}", Encoding.UTF8, "application/json"),
            ct
        );
        response.EnsureSuccessStatusCode();
        var body = await response.Content.ReadAsStringAsync(ct);
        return JsonSerializer.Deserialize<ListDartTestsResponse>(body, _json)
            ?? throw new InvalidOperationException("Empty listDartTests response");
    }

    public async Task<RunDartTestResponse> RunDartTestAsync(string name, CancellationToken ct)
    {
        var payload = JsonSerializer.Serialize(new RunDartTestRequest { Name = name });
        using var response = await _http.PostAsync(
            "runDartTest",
            new StringContent(payload, Encoding.UTF8, "application/json"),
            ct
        );
        response.EnsureSuccessStatusCode();
        var body = await response.Content.ReadAsStringAsync(ct);
        return JsonSerializer.Deserialize<RunDartTestResponse>(body, _json)
            ?? throw new InvalidOperationException("Empty runDartTest response");
    }
}

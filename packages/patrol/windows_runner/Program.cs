using Patrol.WindowsRunner;

if (args.Length == 0 || args.Contains("--help") || args.Contains("-h"))
{
    PrintUsage();
    return 0;
}

string? appPath = null;
var testPort = 8081;
var appPort = 8082;

for (var i = 0; i < args.Length; i++)
{
    switch (args[i])
    {
        case "--app":
            appPath = RequireValue(args, ref i, "--app");
            break;
        case "--test-port":
            testPort = int.Parse(RequireValue(args, ref i, "--test-port"));
            break;
        case "--app-port":
            appPort = int.Parse(RequireValue(args, ref i, "--app-port"));
            break;
        default:
            Console.Error.WriteLine($"Unknown argument: {args[i]}");
            PrintUsage();
            return 64;
    }
}

if (string.IsNullOrWhiteSpace(appPath) || !File.Exists(appPath))
{
    Console.Error.WriteLine($"--app must point to an existing executable, got: {appPath}");
    return 64;
}

using var cts = new CancellationTokenSource();
Console.CancelKeyPress += (_, e) =>
{
    e.Cancel = true;
    cts.Cancel();
};

try
{
    var orchestrator = new TestOrchestrator(appPath, testPort, appPort);
    return await orchestrator.RunAsync(cts.Token);
}
catch (OperationCanceledException)
{
    Console.Error.WriteLine("Cancelled");
    return 130;
}
catch (Exception ex)
{
    Console.Error.WriteLine($"Fatal: {ex}");
    return 1;
}

static string RequireValue(string[] args, ref int i, string name)
{
    if (i + 1 >= args.Length)
    {
        throw new ArgumentException($"Missing value for {name}");
    }

    return args[++i];
}

static void PrintUsage()
{
    Console.WriteLine(
        """
        patrol_windows_runner — Patrol Windows POC native host

        Usage:
          patrol_windows_runner --app <path-to-flutter-exe> [--test-port 8081] [--app-port 8082]
        """
    );
}

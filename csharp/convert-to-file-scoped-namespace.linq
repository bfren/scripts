<Query Kind="Statements">
  <NuGetReference>Jeebs</NuGetReference>
  <NuGetReference>Jeebs.Option</NuGetReference>
  <NuGetReference>Jeebs.Random</NuGetReference>
  <Namespace>F</Namespace>
  <Namespace>Jeebs</Namespace>
  <Namespace>Jeebs.Linq</Namespace>
  <Namespace>static F.OptionF</Namespace>
</Query>

// Safety switch - set to true to save changes
var disengageSafetySwitch = true;

// Update all files in this path
var path = @"Q:\src\jeebs\v6\src\";

// Alias new line
var nl = Environment.NewLine;

// Create regular expressions - they are compiled for speed
var allNamespacesRe = new Regex(@$"namespace ([a-z_A-Z\.]+){nl}{{", RegexOptions.Singleline | RegexOptions.Compiled);
var componentsRe = new Regex(@$"(.*)namespace ([a-z_A-Z\.]+){nl}{{(.*)}}", RegexOptions.Singleline | RegexOptions.Compiled);
var firstTabRe = new Regex("^\t", RegexOptions.Compiled);

// Ignore filenames
var ignoreFiles = new List<string>
{
	@"\obj\",
	"Resources.Designer.cs"
};

// Check each file
var files = Directory.GetFiles(path, "*.cs", SearchOption.AllDirectories);
var ignoredFiles = new List<string>();
var updatedFiles = new List<string>();
foreach (var file in files)
{
	// Check ignore files
	if (ignoreFiles.Any(ignore => file.Contains(ignore)))
	{
		ignoredFiles.Add(file);
		continue;
	}

	// Get file contents
	var contents = await File.ReadAllTextAsync(file);

	// Make sure there is only one namespace definition
	var allNamespaces = allNamespacesRe.Matches(contents);
	if (allNamespaces.Count > 1)
	{
		$"Multiple namespaces: {file}".Dump();
		continue;
	}

	// Match components
	var components = componentsRe.Match(contents);
	if (!components.Success)
	{
		$"No match: {file}".Dump();
		continue;
	}

	// Get header, namespace, and code
	var header = components.Groups[1].Value.Trim();
	var ns = $"namespace {components.Groups[2].Value.Trim()};";
	var code = components.Groups[3].Value.Split('\n');

	// Remove the tab from the beginning of every line
	var newCode = new List<string>();
	foreach (var line in code)
	{
		var trimmed = firstTabRe.Replace(line, "");
		newCode.Add(trimmed);
	}

	// Rebuild code contents
	var newContents = header + nl + nl + ns + nl + string.Join('\n', newCode);

	// Save file with same encoding as before
	updatedFiles.Add(file);	
	if (disengageSafetySwitch)
	{
		await File.WriteAllTextAsync(file, newContents, getEncoding(file));
	}
}

updatedFiles.Dump(disengageSafetySwitch ? "Updated" : "To be updated");
ignoredFiles.Dump("Ignored");

// Get encoding of specified file, or default encoding if not detected
Encoding getEncoding(string path)
{
	using var reader = new StreamReader(path, Encoding.Default, true);
	if (reader.Peek() >= 0)
	{
		reader.Read(); // encoding detection is not done until first call to read method
		return reader.CurrentEncoding;
	}
	else
	{
		return Encoding.Default;
	}	
}
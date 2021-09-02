<Query Kind="Statements">
  <IncludeUncapsulator>false</IncludeUncapsulator>
</Query>

// Copyright (c) bfren - licensed under https://mit.bfren.dev/2021


var version = "0.1.2109020900";


// =========================================================================================================================== //
//                                                                                                                             //
// Script settings - adjust these to suit your environment.                                                                    //
//                                                                                                                             //
// =========================================================================================================================== //

// Safety switch - set to true to save changes
var disengageSafetySwitch = false;

// Update all files in this path
var path = @"";

// Ignore files containing any of these literals
var ignoreFiles = new List<string>
{
	@"\obj\",
	"Resources.Designer.cs"
};


// =========================================================================================================================== //
//                                                                                                                             //
// From this point on, here be dragons!                                                                                        //
//                                                                                                                             //
// =========================================================================================================================== //

// Output version
version.Dump("Script version");

// Alias new line
var nl = Environment.NewLine;

// Create regular expressions - they are compiled for speed
var allNamespacesRe = new Regex(@$"namespace ([a-z_A-Z\.]+){nl}{{", RegexOptions.Singleline | RegexOptions.Compiled);
var componentsRe = new Regex(@$"(.*)namespace ([a-z_A-Z\.]+){nl}{{(.*)}}", RegexOptions.Singleline | RegexOptions.Compiled);
var firstTabRe = new Regex("^\t", RegexOptions.Compiled);

// Check path
if (string.IsNullOrWhiteSpace(path))
{
	"Path cannot be empty.".Dump();
	return;
}

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
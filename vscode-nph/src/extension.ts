// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
import * as child_process from "child_process";
import * as vscode from "vscode";

function rangeWholeFile(doc: vscode.TextDocument): vscode.Range {
  let lastlinum = doc.lineCount - 1;
  let first = doc.lineAt(0).range.start.character;
  let last = doc.lineAt(lastlinum).range.end.character;
  return new vscode.Range(0, first, lastlinum, last);
}

function getFormattedString(doc: vscode.TextDocument): string {
  const workspaceDir = vscode.workspace.getWorkspaceFolder(doc.uri);
  const filePath = doc.uri.fsPath;

  try {
    // Use --strict-filters to respect exclude/include patterns even for explicitly passed files
    // Use --out:- to write formatted output to stdout
    // This allows nph to check exclude/include patterns based on the actual file path
    return child_process
      .execSync(`nph --strict-filters --out:- "${filePath}"`, {
        encoding: "utf-8",
        cwd: workspaceDir?.uri.fsPath
      })
      .toString();
  } catch (error: any) {
    // If nph exits with an error (e.g., file is excluded or syntax error),
    // return the original content unchanged
    return doc.getText();
  }
}

// this method is called when your extension is activated
// your extension is activated the very first time the command is executed
export function activate(context: vscode.ExtensionContext) {
  let provider = {
    provideDocumentFormattingEdits(
      doc: vscode.TextDocument
    ): vscode.TextEdit[] {
      return [
        vscode.TextEdit.replace(rangeWholeFile(doc), getFormattedString(doc))
      ];
    }
  };
  context.subscriptions.push(vscode.languages.registerDocumentFormattingEditProvider(
    "nim", provider
  ));
  context.subscriptions.push(vscode.languages.registerDocumentFormattingEditProvider(
    "nims", provider
  ));
  context.subscriptions.push(vscode.languages.registerDocumentFormattingEditProvider(
    "nimble", provider
  ));
}

// this method is called when your extension is deactivated
export function deactivate() { }
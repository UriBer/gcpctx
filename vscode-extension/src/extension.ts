import * as vscode from 'vscode';

export function activate(context: vscode.ExtensionContext) {
    console.log('gcpctx Skills extension is now active');

    // The skills are automatically contributed via package.json
    // This extension primarily serves as a container for the skill bundles

    // Register a command to open the gcpctx documentation
    const openDocsCommand = vscode.commands.registerCommand(
        'gcpctx.openDocs',
        () => {
            vscode.env.openExternal(
                vscode.Uri.parse('https://github.com/UriBer/gcpctx')
            );
        }
    );

    // Register a command to show available skills
    const showSkillsCommand = vscode.commands.registerCommand(
        'gcpctx.showSkills',
        () => {
            const skills = [
                {
                    name: 'gcpctx-usage',
                    description: 'Initialize and switch between GCP contexts'
                },
                {
                    name: 'gcpctx-safety',
                    description: 'Safely manage GCP production environments'
                },
                {
                    name: 'gcpctx-troubleshooting',
                    description: 'Troubleshoot gcpctx issues and fix credential problems'
                },
                {
                    name: 'gcpctx-cicd',
                    description: 'Set up gcpctx in CI/CD pipelines'
                }
            ];

            const items = skills.map(skill => ({
                label: skill.name,
                detail: skill.description
            }));

            vscode.window.showQuickPick(items, {
                placeHolder: 'Available gcpctx AI skills'
            });
        }
    );

    context.subscriptions.push(openDocsCommand, showSkillsCommand);
}

export function deactivate() {}

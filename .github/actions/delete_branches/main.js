const core = require("@actions/core");
const github = require("@actions/github");

function removeDuplicates(arr) {
  return [...new Set(arr)];
}

async function main() {
  try {
    const token = core.getInput("github_token", { required: true });
    const branches = core.getInput("branches");
    const prefix = core.getInput("prefix");
    const suffix = core.getInput("suffix");

    const client = github.getOctokit(token);

    let branchesToDelete = branches ? branches.split(",") : [];

    if (prefix) {
      branchesToDelete.push(
        branches.filter((branch) => branch.startsWith(prefix))
      );
    }

    if (suffix) {
      branchesToDelete.push(
        branches.filter((branch) => branch.endsWith(suffix))
      );
    }

    branchesToDelete = removeDuplicates(branchesToDelete);

    for (const branch of branchesToDelete) {
      await client.git.deleteRef({
        owner: github.context.repo.owner,
        repo: github.context.repo.repo,
        ref: `heads/${branch}`,
      });
    }
  } catch (error) {
    core.setFailed(error.message);
  }
}

main();

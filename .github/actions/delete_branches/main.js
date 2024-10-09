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

    const allBranches = await client.rest.repos.listBranches({
      owner: github.context.repo.owner,
      repo: github.context.repo.repo,
      per_page: 1000,
    });

    if (prefix) {
      branchesToDelete.push(
        allBranches.data
          .filter((branch) => branch.name.startsWith(prefix))
          .map((branch) => branch.name)
      );
    }

    if (suffix) {
      branchesToDelete.push(
        allBranches
          .filter((branch) => branch.name.endsWith(suffix))
          .map((branch) => branch.name)
      );
    }

    // branchesToDelete = removeDuplicates(branchesToDelete);

    for (const branch of branchesToDelete) {
      console.log(branch);
      await client.rest.git.deleteRef({
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

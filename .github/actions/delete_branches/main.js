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
      allBranches.data
        .filter((branch) => branch.name.startsWith(prefix))
        .map((branch) => branch.name)
        .forEach((branch) => branchesToDelete.push(branch));
    }

    if (suffix) {
      allBranches.data
        .filter((branch) => branch.name.endsWith(prefix))
        .map((branch) => branch.name)
        .forEach((branch) => branchesToDelete.push(branch));
    }

    branchesToDelete = removeDuplicates(branchesToDelete);

    for (const branch of branchesToDelete) {
      console.log(branch);
      console.log(typeof branch);
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

// .github/scripts/comment-pr.mjs
import { createAppAuth } from "@octokit/auth-app";
import { Octokit } from "@octokit/rest";
import fs from "fs";

const privateKey = Buffer.from(process.env.PRIVATE_KEY, "base64").toString("utf8");
const appId = process.env.APP_ID;
const installationId = process.env.INSTALLATION_ID;
const repoFullName = process.env.REPO;
const [owner, repo] = repoFullName.split("/");
const prNumber = parseInt(process.env.PR_NUMBER, 10);

const COMMENT_TAG = "<!-- terraform-plan-comment -->";

const auth = createAppAuth({
  appId,
  privateKey,
  installationId,
});

const installationAuthentication = await auth({ type: "installation" });
const octokit = new Octokit({ auth: installationAuthentication.token });

const planBody = fs.readFileSync("plan.txt", "utf8");
const commentBody = `${COMMENT_TAG}\n### 📦 Terraform Plan Result\n\`\`\`\n${planBody}\n\`\`\``;

const { data: comments } = await octokit.issues.listComments({
  owner,
  repo,
  issue_number: prNumber,
});

const existingComment = comments.find(c => c.body.includes(COMMENT_TAG));

if (existingComment) {
  console.log("🔁 Updating existing Terraform plan comment...");
  await octokit.issues.updateComment({
    owner,
    repo,
    comment_id: existingComment.id,
    body: commentBody,
  });
} else {
  console.log("🆕 Creating new Terraform plan comment...");
  await octokit.issues.createComment({
    owner,
    repo,
    issue_number: prNumber,
    body: commentBody,
  });
}

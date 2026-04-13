/**
 * Helper script for posting PR comments
 * This script is used by the terraform workflows to post formatted comments to PRs
 */

const fs = require('fs');

/**
 * Format terraform output for GitHub markdown
 * @param {string} output - The terraform output
 * @param {number} maxLength - Maximum length before truncation
 * @returns {string} Formatted markdown
 */
function formatTerraformOutput(output, maxLength = 6000) {
  if (output.length > maxLength) {
    return output.substring(0, maxLength) + '\n\n... (output truncated)';
  }
  return output;
}

/**
 * Create a plan summary comment body
 * @param {boolean} success - Whether the plan succeeded
 * @param {string} output - The plan output
 * @param {number} prNumber - The PR number
 * @returns {string} Comment body
 */
function createPlanCommentBody(success, output, prNumber) {
  const formattedOutput = formatTerraformOutput(output);

  if (success) {
    return `## Terraform Plan Summary

✅ **Terraform Plan Successful**

The terraform plan completed successfully for PR #${prNumber}. You can now review the changes.

<details><summary>Plan Output</summary>

\`\`\`
${formattedOutput}
\`\`\`

</details>

**Next Steps:**
1. Review the plan above
2. Get the PR approved
3. Comment \`/apply\` to run terraform apply`;
  } else {
    return `## Terraform Plan Summary

❌ **Terraform Plan Failed**

The terraform plan encountered errors for PR #${prNumber}. Please review the logs and fix any issues.

<details><summary>Plan Output</summary>

\`\`\`
${formattedOutput}
\`\`\`

</details>

**Please fix the errors and re-run \`/plan\` to generate a new plan.**`;
  }
}

/**
 * Create an apply summary comment body
 * @param {boolean} success - Whether the apply succeeded
 * @param {string} output - The apply output
 * @param {number} prNumber - The PR number
 * @returns {string} Comment body
 */
function createApplyCommentBody(success, output, prNumber) {
  const formattedOutput = formatTerraformOutput(output);

  if (success) {
    return `## Terraform Apply Summary

✅ **Terraform Apply Successful**

The terraform apply completed successfully for PR #${prNumber}.

<details><summary>Apply Output</summary>

\`\`\`
${formattedOutput}
\`\`\`

</details>`;
  } else {
    return `## Terraform Apply Summary

❌ **Terraform Apply Failed**

The terraform apply encountered errors for PR #${prNumber}.

<details><summary>Apply Output</summary>

\`\`\`
${formattedOutput}
\`\`\`

</details>

**Please review the errors and take appropriate action.**`;
  }
}

module.exports = {
  formatTerraformOutput,
  createPlanCommentBody,
  createApplyCommentBody
};

// If run directly (for testing)
if (require.main === module) {
  const testOutput = 'An example terraform output\nResource: google_service_account.data_pipeline';
  console.log('Plan comment (success):');
  console.log(createPlanCommentBody(true, testOutput, 123));
  console.log('\n---\n');
  console.log('Plan comment (failure):');
  console.log(createPlanCommentBody(false, testOutput, 123));
}

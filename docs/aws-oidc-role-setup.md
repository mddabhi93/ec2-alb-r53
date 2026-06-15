# AWS OIDC role setup for GitHub Actions

Use an IAM role in your AWS account that GitHub Actions can assume through OpenID Connect (OIDC).

## 1. Create an IAM role

Create a role with trust policy similar to the following:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": [
            "repo:<OWNER>/<REPO>:ref:refs/heads/main",
            "repo:<OWNER>/<REPO>:pull_request"
          ]
        }
      }
    }
  ]
}
```

If you want to allow all branches, tags, and pull requests, use a broader condition like:

```json
"token.actions.githubusercontent.com:sub": "repo:<OWNER>/<REPO>:*"
```

## 2. Attach permissions

Attach the minimum required policies to the role, for example:

- AmazonEC2FullAccess
- AmazonRoute53FullAccess
- AmazonSSMManagedInstanceCore
- AmazonVPCFullAccess
- AmazonElasticLoadBalancingFullAccess
- IAMReadOnlyAccess or a narrower custom policy
- AmazonS3FullAccess if using remote state

For production, prefer a scoped custom policy instead of full access.

## 3. Add GitHub secret or repository variable

In GitHub, create a repository variable or secret for the role ARN:

- Name: AWS_ROLE_ARN
- Value: arn:aws:iam::<ACCOUNT_ID>:role/<ROLE_NAME>

If you store it as a secret, the workflow will still pick it up automatically. The workflow uses the GitHub environment named dev-apply for both plan and apply, so you can also store the value as an environment-scoped variable or secret for that environment.

## 4. Update the workflow

Use the role ARN from GitHub Actions:

```yaml
with:
  role-to-assume: ${{ vars.AWS_ROLE_ARN || secrets.AWS_ROLE_ARN }}
  aws-region: us-east-1
```

## 5. Enable OIDC in GitHub

This is usually automatic for GitHub-hosted runners when using the official AWS action.

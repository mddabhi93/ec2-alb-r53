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
          "token.actions.githubusercontent.com:sub": "repo:<OWNER>/<REPO>:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

If you want to allow pull requests too, use a condition like:

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

## 4. Update the workflow

Use the role ARN from GitHub Actions:

```yaml
with:
  role-to-assume: ${{ vars.AWS_ROLE_ARN }}
  aws-region: us-east-1
```

## 5. Enable OIDC in GitHub

This is usually automatic for GitHub-hosted runners when using the official AWS action.

# AWS Credential Setup Guide

This guide explains how to configure AWS credentials for deploying Lambda functions using the CARTO Analytics Toolbox Gateway.

## Quick Start

The gateway supports multiple authentication methods. Choose the one that best fits your environment:

1. **AWS Profile** - Recommended for local development
2. **Explicit Credentials** - For CI/CD pipelines
3. **IAM Role** - For EC2/ECS/Lambda environments
4. **AWS SSO** - For enterprise environments

**Advanced:** For cross-account deployments, see Method 3: Assume Role below.

## Method 1: AWS Profile (Recommended)

### Setup

1. Configure AWS CLI:
```bash
aws configure --profile my-profile
# Enter: Access Key ID, Secret Access Key, Region, Output format
```

2. Set in `.env`:
```bash
AWS_PROFILE=my-profile
AWS_REGION=us-east-1
```

3. Deploy:
```bash
make deploy
```

### Advantages
- ✅ Credentials stored securely in `~/.aws/credentials`
- ✅ Supports multiple profiles for different environments
- ✅ Easy to switch between accounts
- ✅ No credentials in code or environment variables

### When to Use
- Local development
- Multiple AWS accounts
- Team members with different AWS credentials

---

## Method 2: Explicit Credentials

### Setup

1. Get your AWS credentials from IAM console

2. Set in `.env`:
```bash
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
# Optional for temporary credentials:
# AWS_SESSION_TOKEN=...
```

3. Deploy:
```bash
make deploy
```

### Advantages
- ✅ Simple and straightforward
- ✅ Works in any environment
- ✅ Good for CI/CD pipelines

### Disadvantages
- ⚠️ Credentials visible in environment
- ⚠️ Must secure `.env` file
- ⚠️ Rotation requires updating `.env`

### When to Use
- CI/CD pipelines (GitHub Actions, GitLab CI, etc.)
- Docker containers
- Environments without AWS CLI

### Security Best Practice

For CI/CD, use secrets management:

**GitHub Actions:**
```yaml
- name: Deploy to AWS
  env:
    AWS_REGION: ${{ secrets.AWS_REGION }}
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  run: make deploy
```

**GitLab CI:**
```yaml
deploy:
  variables:
    AWS_REGION: $AWS_REGION
    AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
  script:
    - make deploy
```

---

## Method 3: Assume Role (Cross-Account)

### Setup

1. Create a role in target account with trust policy:
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "AWS": "arn:aws:iam::SOURCE-ACCOUNT:user/deployer"
    },
    "Action": "sts:AssumeRole"
  }]
}
```

2. Set in `.env`:
```bash
AWS_PROFILE=my-profile  # or use explicit credentials
AWS_REGION=us-east-1
AWS_ASSUME_ROLE_ARN=arn:aws:iam::123456789:role/DeployerRole
```

3. Deploy:
```bash
make deploy
```

### Advantages
- ✅ Cross-account deployments
- ✅ Temporary elevated permissions
- ✅ Audit trail via CloudTrail
- ✅ Can limit session duration

### When to Use
- Deploying Lambda to different AWS account than Redshift
- Assuming roles with elevated permissions temporarily
- Multi-account organizations
- Third-party deployments

### Example: Cross-Account Deployment

**Scenario:** Lambda in Account A, Redshift in Account B

```bash
# .env
AWS_PROFILE=account-a-profile
AWS_REGION=us-east-1
AWS_ASSUME_ROLE_ARN=arn:aws:iam::ACCOUNT-A-ID:role/LambdaDeployerRole

# Lambda will be deployed in Account A
LAMBDA_PREFIX=carto-at-

# Redshift in Account B will invoke Lambda via cross-account permission
RS_ROLES=arn:aws:iam::ACCOUNT-B-ID:role/RedshiftLambdaRole
```

After deployment, add Lambda permission:
```bash
aws lambda add-permission \
  --function-name carto-at-quadbin_polyfill \
  --statement-id redshift-cross-account \
  --action lambda:InvokeFunction \
  --principal arn:aws:iam::ACCOUNT-B-ID:role/RedshiftLambdaRole
```

---

## Method 4: IAM Role (EC2/ECS/Lambda)

### Setup

1. Attach IAM role to your EC2 instance, ECS task, or Lambda function

2. Set in `.env` (optional):
```bash
AWS_REGION=us-east-1
# No credentials needed - IAM role is auto-discovered
```

3. Deploy:
```bash
make deploy
```

### Advantages
- ✅ No credentials to manage
- ✅ Automatic credential rotation
- ✅ Most secure option
- ✅ AWS best practice

### When to Use
- Running on EC2 instances
- ECS/Fargate containers
- Lambda functions deploying other Lambdas
- AWS Cloud9 environments

### Example: EC2 Deployment

1. Create IAM role with Lambda deployment permissions:
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "lambda:CreateFunction",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:GetFunction",
      "iam:PassRole"
    ],
    "Resource": "*"
  }]
}
```

2. Attach role to EC2 instance

3. SSH to EC2 and deploy:
```bash
cd analytics-toolbox-gateway
make deploy  # No credentials needed!
```

---

## Method 5: AWS SSO (Enterprise)

### Setup

1. Configure AWS SSO:
```bash
aws configure sso
# Follow prompts to set up SSO profile
```

2. Login:
```bash
aws sso login --profile my-sso-profile
```

3. Set in `.env`:
```bash
AWS_PROFILE=my-sso-profile
AWS_REGION=us-east-1
```

4. Deploy:
```bash
make deploy
```

### Advantages
- ✅ Enterprise-grade authentication
- ✅ Centralized access management
- ✅ Multi-factor authentication
- ✅ Temporary credentials
- ✅ Compliance-friendly

### When to Use
- Enterprise environments using AWS IAM Identity Center
- Organizations with strict security requirements
- Need for MFA enforcement
- Centralized user management

### Re-authentication

SSO sessions expire. Before deploying, ensure you're logged in:
```bash
aws sso login --profile my-sso-profile
make deploy
```

---

## Testing Your Credentials

Test your credential setup:

```bash
cd gateway
venv/bin/python test_credentials.py
```

This will test all configured authentication methods and report which ones work.

---

## Troubleshooting

### "The security token included in the request is invalid"

**Cause:** Invalid or expired credentials

**Solutions:**
- Check AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are correct
- For SSO: Run `aws sso login --profile <profile>`
- For assumed roles: Check role trust policy allows your user

### "Access Denied" / "not authorized to perform: lambda:CreateFunction"

**Cause:** Insufficient IAM permissions

**Solution:** Ensure your user/role has required permissions:
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "lambda:CreateFunction",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:GetFunction",
      "iam:PassRole"
    ],
    "Resource": "*"
  }]
}
```

### "Cannot find credentials"

**Cause:** No credentials configured

**Solutions:**
1. Set AWS_PROFILE in `.env`
2. Or set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
3. Or run `aws configure` to set up default profile

### Profile not found

**Cause:** AWS_PROFILE references non-existent profile

**Solution:** Check available profiles:
```bash
aws configure list-profiles
```

Then use one of the listed profiles in `.env`:
```bash
AWS_PROFILE=<existing-profile-name>
```

---

## Security Best Practices

1. **Never commit `.env` files** to git
   - Add `.env` to `.gitignore`
   - Use `.env.template` for documentation

2. **Rotate credentials regularly**
   - AWS recommends rotating access keys every 90 days
   - Use temporary credentials when possible (SSO, assume role)

3. **Use least privilege**
   - Grant only permissions needed for deployment
   - Use separate IAM users for different environments

4. **Enable MFA**
   - Require MFA for IAM users
   - Use AWS SSO with MFA enforcement

5. **Monitor access**
   - Enable CloudTrail logging
   - Review IAM access regularly
   - Use AWS Access Analyzer

6. **Prefer IAM roles over access keys**
   - Use IAM roles for EC2/ECS/Lambda
   - Use AWS SSO for user access
   - Reserve access keys for CI/CD only

---

## Recommended Setup by Environment

| Environment | Recommended Method | Why |
|-------------|-------------------|-----|
| **Local Development** | AWS Profile | Secure, easy to manage multiple accounts |
| **CI/CD** | Explicit Credentials | Simple, works in any CI/CD system |
| **EC2/ECS** | IAM Role | No credentials to manage, most secure |
| **Enterprise** | AWS SSO | MFA, centralized management, compliance |
| **Cross-Account** | Assume Role | Clear separation, audit trail |

---

## Need Help?

- Check [AWS CLI Configuration Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
- Review [AWS Security Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- See [AWS SSO Documentation](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html)

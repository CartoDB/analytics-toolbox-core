#!/usr/bin/env python3
"""
Test script to verify all AWS credential authentication methods work
"""
import sys
from pathlib import Path

# Add paths for imports
sys.path.insert(0, str(Path(__file__).parent / "logic" / "platforms" / "aws-lambda"))
sys.path.insert(
    0, str(Path(__file__).parent / "logic" / "platforms" / "aws-lambda" / "deploy")
)

from deployer import LambdaDeployer


def test_credential_method(name: str, **kwargs):
    """Test a credential method"""
    print(f"\n{'='*60}")
    print(f"Testing: {name}")
    print(f"{'='*60}")

    try:
        deployer = LambdaDeployer(**kwargs)
        print(f"✓ {name} - Success!")
        print(f"  Account ID: {deployer.account_id}")
        print(f"  Region: {deployer.region}")
        return True
    except Exception as e:
        print(f"✗ {name} - Failed: {e}")
        return False


def main():
    print("AWS Credential Authentication Method Tests")
    print("=" * 60)

    results = {}

    # Test 1: Default credential chain (env vars or IAM role)
    results["Default Chain"] = test_credential_method(
        "Method 1: Default Credential Chain (env vars or IAM role)",
        region="us-east-1",
    )

    # Test 2: AWS Profile (only if AWS_PROFILE is set)
    import os

    profile = os.getenv("AWS_PROFILE")
    if profile:
        results["AWS Profile"] = test_credential_method(
            f"Method 2: AWS Profile ({profile})",
            region="us-east-1",
            profile=profile,
        )
    else:
        print(
            "\n⊘ Skipping Method 2 (AWS Profile) - AWS_PROFILE not set in environment"
        )

    # Test 3: Explicit credentials (only if set)
    access_key = os.getenv("AWS_ACCESS_KEY_ID")
    secret_key = os.getenv("AWS_SECRET_ACCESS_KEY")
    session_token = os.getenv("AWS_SESSION_TOKEN")

    if access_key and secret_key:
        results["Explicit Credentials"] = test_credential_method(
            "Method 3: Explicit Credentials",
            region="us-east-1",
            access_key_id=access_key,
            secret_access_key=secret_key,
            session_token=session_token,
        )
    else:
        print(
            "\n⊘ Skipping Method 3 (Explicit Credentials) - "
            "AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY not set"
        )

    # Test 4: Assume Role (only if role ARN is set)
    role_arn = os.getenv("AWS_ASSUME_ROLE_ARN")
    if role_arn:
        results["Assume Role"] = test_credential_method(
            f"Method 4: Assume Role ({role_arn})",
            region="us-east-1",
            role_arn=role_arn,
        )
    else:
        print("\n⊘ Skipping Method 4 (Assume Role) - AWS_ASSUME_ROLE_ARN not set")

    # Summary
    print(f"\n{'='*60}")
    print("Test Summary")
    print(f"{'='*60}")

    passed = sum(1 for v in results.values() if v)
    total = len(results)

    for method, result in results.items():
        status = "✓ PASS" if result else "✗ FAIL"
        print(f"{status}: {method}")

    print(f"\nTotal: {passed}/{total} tests passed")

    if passed == total:
        print("\n✓ All credential methods working correctly!")
        return 0
    else:
        print(f"\n⚠ {total - passed} credential method(s) failed")
        return 1


if __name__ == "__main__":
    sys.exit(main())

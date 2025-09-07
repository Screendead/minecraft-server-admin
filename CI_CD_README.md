# CI/CD Setup for Minecraft Server Admin

This project uses GitHub Actions for automated builds, testing, and deployments.

## 🚀 Deployment Workflows

### Master Branch Deployment
- **Trigger**: Push to `master` branch
- **Actions**:
  - Runs Flutter tests with coverage
  - Uploads coverage data to Codecov
  - Builds the web app for production
  - Deploys to Firebase Hosting (main site)
  - Updates coverage badge automatically

### PR Preview Deployment
- **Trigger**: Pull Request opened, updated, or reopened
- **Actions**:
  - Runs Flutter tests with coverage
  - **Enforces 100% test coverage requirement** (build fails if not met)
  - Builds the web app
  - Deploys to Firebase Hosting channel for PR preview
  - Deploys coverage report to subdirectory of same channel
  - Comments on PR with preview links
  - Updates comment when PR is updated

### PR Cleanup
- **Trigger**: Pull Request closed
- **Actions**:
  - Deletes Firebase Hosting channel
  - Comments on PR confirming cleanup

## 🔧 Required Secrets

Add these secrets to your GitHub repository settings:

1. **FIREBASE_TOKEN**: Firebase CLI token for authentication
   - Generate with: `firebase login:ci`
   - Add to: Repository Settings → Secrets and variables → Actions

## 📊 Code Coverage

- **100% test coverage required** for all PR merges
- Coverage reports are generated for every test run
- **Codecov integration** for master branch coverage tracking
- **Dynamic coverage badge** in README shows current coverage
- PR previews include a separate coverage report URL
- Build fails if coverage is below 100%

## 🌐 Deployment URLs

### Production
- **Main Site**: `https://minecraft-server-automation.web.app`
- **Custom Domain**: (if configured in Firebase)

### PR Previews
- **App Preview**: `https://minecraft-server-automation--pr-{PR_NUMBER}.web.app`
- **Coverage Report**: `https://minecraft-server-automation--pr-{PR_NUMBER}.web.app/coverage/`

## 🛠️ Local Development

### Running Tests
```bash
cd app
flutter test --coverage
```

### Building for Web
```bash
cd app
flutter build web --release
```

### Starting Firebase Emulators
```bash
cd app
./start_emulators.sh
```

## 📁 Workflow Files

- `.github/workflows/deploy-master.yml` - Master branch deployment (production)
- `.github/workflows/pr-deploy.yml` - PR preview deployment and cleanup

## 🔍 Monitoring

- Check the Actions tab in GitHub for workflow status
- **Coverage badge** in README shows current master branch coverage
- **Codecov dashboard** provides detailed coverage analysis
- PR comments will show deployment status and URLs
- Coverage reports are available in workflow artifacts

## 🚨 Troubleshooting

### Common Issues

1. **Firebase Token Expired**
   - Regenerate token: `firebase login:ci`
   - Update secret in repository settings

2. **Build Failures**
   - Check Flutter version compatibility
   - Verify all dependencies are properly configured
   - **Coverage failures**: Ensure 100% test coverage before merging

3. **Deployment Failures**
   - Ensure Firebase project exists and is accessible
   - Check Firebase hosting configuration

### Getting Help

- Check workflow logs in GitHub Actions
- Review Firebase console for deployment issues
- Ensure all required secrets are properly configured

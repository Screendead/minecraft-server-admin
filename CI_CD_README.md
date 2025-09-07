# CI/CD Setup for Minecraft Server Admin

This project uses GitHub Actions for automated builds, testing, and deployments.

## 🚀 Deployment Workflows

### Master Branch Deployment
- **Trigger**: Push to `master` branch
- **Actions**:
  - Runs Flutter tests with coverage
  - Builds the web app for production
  - Deploys to Firebase Hosting (main site)
  - Uploads coverage reports as artifacts

### PR Preview Deployment
- **Trigger**: Pull Request opened, updated, or reopened
- **Actions**:
  - Runs Flutter tests with coverage
  - Builds the web app
  - Creates temporary Firebase project for PR preview
  - Deploys app to temporary URL
  - Creates separate temporary Firebase project for coverage report
  - Deploys coverage report to temporary URL
  - Comments on PR with preview links
  - Updates comment when PR is updated

### PR Cleanup
- **Trigger**: Pull Request closed
- **Actions**:
  - Deletes temporary Firebase projects
  - Comments on PR confirming cleanup

## 🔧 Required Secrets

Add these secrets to your GitHub repository settings:

1. **FIREBASE_TOKEN**: Firebase CLI token for authentication
   - Generate with: `firebase login:ci`
   - Add to: Repository Settings → Secrets and variables → Actions

## 📊 Code Coverage

- Coverage reports are generated for every test run
- PR previews include a separate coverage report URL
- Coverage data is uploaded as artifacts for each workflow run

## 🌐 Deployment URLs

### Production
- **Main Site**: `https://minecraft-server-automation.web.app`
- **Custom Domain**: (if configured in Firebase)

### PR Previews
- **App Preview**: `https://minecraft-server-admin-pr-{PR_NUMBER}.web.app`
- **Coverage Report**: `https://minecraft-server-admin-coverage-pr-{PR_NUMBER}.web.app`

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

- `.github/workflows/deploy-master.yml` - Master branch deployment
- `.github/workflows/pr-deploy.yml` - PR preview deployment
- `.github/workflows/cleanup-pr.yml` - PR cleanup
- `.github/workflows/test.yml` - Test runner

## 🔍 Monitoring

- Check the Actions tab in GitHub for workflow status
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

3. **Deployment Failures**
   - Ensure Firebase project exists and is accessible
   - Check Firebase hosting configuration

### Getting Help

- Check workflow logs in GitHub Actions
- Review Firebase console for deployment issues
- Ensure all required secrets are properly configured

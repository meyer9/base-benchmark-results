# GitHub Pages Setup Guide

This guide walks you through setting up automatic deployment of benchmark reports to GitHub Pages.

## Prerequisites

- A GitHub repository with this code
- Admin access to the repository settings
- Benchmark result data in the `results/` folder

## Step 1: Enable GitHub Pages

1. Navigate to your repository on GitHub
2. Click on **Settings** (in the top menu)
3. Scroll down to **Pages** in the left sidebar
4. Under **Source**, select **GitHub Actions** from the dropdown

![GitHub Pages Source Selection](https://docs.github.com/assets/cb-47267/mw-1440/images/help/pages/create-pages-from-actions.webp)

## Step 2: Verify Workflow Permissions

The workflow requires specific permissions to deploy to GitHub Pages:

1. Go to **Settings** → **Actions** → **General**
2. Scroll to **Workflow permissions**
3. Ensure "Read and write permissions" is selected, or at minimum:
   - Read repository contents
   - Write to GitHub Pages

## Step 3: Trigger the Workflow

### Automatic Trigger
The workflow automatically runs when you push to the `main` branch:

```bash
git add .
git commit -m "Add benchmark results"
git push origin main
```

### Manual Trigger
You can also manually trigger the workflow:

1. Go to the **Actions** tab
2. Select **Deploy Benchmark Reports to GitHub Pages**
3. Click **Run workflow**
4. Select the `main` branch
5. Click **Run workflow**

## Step 4: Monitor Deployment

1. Go to the **Actions** tab
2. Click on the running workflow
3. Watch the progress of the `build` and `deploy` jobs
4. Once complete, your reports will be live!

## Step 5: Access Your Reports

After successful deployment:

1. Go to **Settings** → **Pages**
2. You'll see a message like: "Your site is live at https://username.github.io/repo-name/"
3. Click the URL to view the index page with all reports

Each result category has its own sub-URL:
- `https://username.github.io/repo-name/client-comparison/`
- Add more categories by creating new folders in `results/`

## Troubleshooting

### Workflow Fails at Checkout Step
- **Issue**: Permission denied
- **Solution**: Check repository permissions and ensure Actions are enabled

### Workflow Fails at Build Step
- **Issue**: npm install or build errors
- **Solution**: Verify the `github.com/base/benchmark` repository structure hasn't changed

### Workflow Succeeds but Pages Don't Deploy
- **Issue**: Pages source not set to GitHub Actions
- **Solution**: Return to Step 1 and verify Pages source is set correctly

### 404 Error on Deployed Site
- **Issue**: Workflow may have completed but deployment is still processing
- **Solution**: Wait 1-2 minutes and refresh, or check the deploy job logs

### Reports Not Updating
- **Issue**: Browser cache showing old content
- **Solution**: Hard refresh (Ctrl+Shift+R or Cmd+Shift+R)

## Advanced Configuration

### Custom Domain

To use a custom domain:

1. Go to **Settings** → **Pages**
2. Under **Custom domain**, enter your domain
3. Add a `CNAME` file to the root of your repository:

```bash
echo "your-domain.com" > CNAME
git add CNAME
git commit -m "Add custom domain"
git push
```

### Build Optimization

To speed up builds, the workflow caches npm dependencies. If you need to clear the cache:

1. Go to **Actions** → **Caches**
2. Delete the relevant cache
3. Re-run the workflow

### Multiple Branches

To deploy from branches other than `main`, edit `.github/workflows/deploy-pages.yml`:

```yaml
on:
  push:
    branches:
      - main
      - develop  # Add your branch here
```

## Workflow Architecture

The deployment process consists of two jobs:

### Build Job
1. Checks out this repository (results)
2. Checks out the `base/benchmark` repository
3. Installs Node.js and npm dependencies
4. Iterates through each result folder:
   - Copies results to `benchmark/output`
   - Runs `npm run build` in `benchmark/report`
   - Copies built artifacts to deployment staging
5. Creates an index page listing all reports
6. Uploads everything as a Pages artifact

### Deploy Job
1. Takes the artifact from the build job
2. Deploys to GitHub Pages
3. Provides the live URL

## File Structure After Deployment

```
GitHub Pages Root
├── index.html                    # Landing page with links to all reports
├── client-comparison/
│   ├── index.html               # Report for client comparison
│   ├── assets/
│   └── ...
└── [other-results]/
    ├── index.html
    ├── assets/
    └── ...
```

## Support

If you encounter issues not covered here:

1. Check the Actions tab for detailed error logs
2. Review the workflow file: `.github/workflows/deploy-pages.yml`
3. Verify your `results/` folder structure matches the expected format
4. Consult GitHub's [Pages documentation](https://docs.github.com/en/pages)


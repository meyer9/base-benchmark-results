# Base Benchmark Results

This repository contains benchmark results for the Base blockchain and automatically deploys them to GitHub Pages.

## 📊 View Reports

Once deployed, benchmark reports are available at: `https://<your-username>.github.io/<repo-name>/`

Each result category (e.g., `client-comparison`) is published under its own sub-URL:
- `https://<your-username>.github.io/<repo-name>/client-comparison/`

## 🚀 Setup GitHub Pages

To enable automatic deployment to GitHub Pages:

1. Go to your repository's **Settings** → **Pages**
2. Under **Source**, select **GitHub Actions**
3. The workflow will automatically deploy on every push to `main` branch

## 📁 Repository Structure

```
results/
  ├── client-comparison/     # Benchmark result category
  │   ├── metadata.json      # Metadata for all test runs
  │   └── test-*/            # Individual test result folders
  └── ...                    # Additional result categories
```

## 🔄 How It Works

The GitHub Actions workflow (`.github/workflows/deploy-pages.yml`) automatically:

1. **Downloads** the `github.com/base/benchmark` repository
2. **Processes** each result category in the `results/` folder:
   - Copies result data to `benchmark/output`
   - Runs `npm install` in `benchmark/report`
   - Executes `npm run build` to generate the report
3. **Deploys** all built reports to GitHub Pages with each category under its own sub-URL
4. **Creates** an index page listing all available reports

## 🛠️ Manual Deployment

You can manually trigger the deployment workflow:

1. Go to **Actions** tab in GitHub
2. Select **Deploy Benchmark Reports to GitHub Pages**
3. Click **Run workflow**

## 📝 Adding New Results

To add new benchmark results:

1. Create a new folder under `results/` (e.g., `results/new-benchmark/`)
2. Add your benchmark data files
3. Include a `metadata.json` file following the existing structure
4. Commit and push to `main` branch
5. The workflow will automatically build and deploy the new report

## 📄 License

See [LICENSE](LICENSE) for details.

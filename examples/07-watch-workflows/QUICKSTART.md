# Quick Start: Watch Mode Workflows

Get up and running with intelligent watch mode in under 5 minutes.

## Prerequisites

Install `fswatch`:

**macOS:**
```bash
brew install fswatch
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get install fswatch
```

**Verify installation:**
```bash
fswatch --version
gaffer-exec --version
```

## Step 1: Build Everything

```bash
cd examples/07-watch-workflows
./test.sh
```

This will:
- Verify the setup
- Install dependencies
- Build all services
- Run validation tests

Expected output:
```
🧪 Testing Example 07: Watch Mode Workflows
===========================================
...
🎉 All tests passed!
```

## Step 2: Start Watch Mode

In one terminal:
```bash
./scripts/watch-all.sh
```

You should see:
```
🚀 Starting watch mode for all services...
👀 Watching shared-lib for changes...
👀 Watching api-service for changes...
👀 Watching frontend for changes...
✅ All watchers started
```

## Step 3: Make Changes

### Test Shared Library Change

In another terminal:
```bash
# Edit the shared library
echo "// Test change" >> shared-lib/src/index.ts
```

Watch the first terminal — you'll see:
```
🔄 Changed: shared-lib/src/index.ts
   Running: gaffer-exec run rebuild-shared-lib
✅ Rebuild complete

🔄 Running: gaffer-exec run rebuild-api
✅ Rebuild complete

🔄 Running: gaffer-exec run rebuild-frontend
✅ Rebuild complete
```

**Notice**: All three rebuild because they depend on shared-lib!

### Test API Change

```bash
# Edit just the API
echo "// Test change" >> api-service/src/server.ts
```

You'll see:
```
🔄 Changed: api-service/src/server.ts
   Running: gaffer-exec run rebuild-api
✅ Rebuild complete
```

**Notice**: Only API rebuilds (no dependency cascade needed)

## Step 4: Run the Services

In separate terminals:

**Terminal 2 - Start API:**
```bash
cd examples/07-watch-workflows/api-service
node dist/server.js
```

Output:
```
🚀 API service running on http://localhost:4000
📊 Health check: http://localhost:4000/health
👥 Users endpoint: http://localhost:4000/api/users
```

**Terminal 3 - Start Frontend:**
```bash
cd examples/07-watch-workflows/frontend
npx serve -s build -p 3000
```

Output:
```
Serving!
- Local:    http://localhost:3000
- On network: http://192.168.1.x:3000
```

**Terminal 4 - Test API:**
```bash
curl http://localhost:4000/api/users | jq
```

## Step 5: Live Development

Now you have:
- ✅ Three watchers monitoring your code
- ✅ API running on port 4000
- ✅ Frontend running on port 3000

**Try it:**
1. Edit `shared-lib/src/index.ts` → Watch cascade rebuild
2. Edit `api-service/src/server.ts` → Only API rebuilds
3. Restart API service to see changes
4. Edit `frontend/src/App.tsx` → Only frontend rebuilds
5. Refresh browser to see changes

## Common Commands

**Clean everything:**
```bash
gaffer-exec --graph graph.json run clean
```

**Rebuild everything:**
```bash
gaffer-exec --graph graph.json run build-all
```

**Watch individual service:**
```bash
# Just watch shared-lib
./scripts/watch-shared-lib.sh

# Just watch API
./scripts/watch-api.sh

# Just watch frontend
./scripts/watch-frontend.sh
```

**Stop watchers:**
Press `Ctrl+C` in the terminal running watch mode.

## Understanding the Output

### Watch Events

```
🔄 Changed: shared-lib/src/index.ts
   Running: gaffer-exec run rebuild-shared-lib
✅ Rebuild complete
```

- `🔄` = File changed
- `✅` = Rebuild successful
- `❌` = Rebuild failed (check error output)

### Dependency Cascade

When you change `shared-lib`:
1. fswatch detects change
2. Triggers `rebuild-shared-lib`
3. Any watcher trying to rebuild dependent services will see shared-lib changed
4. Those services rebuild too

This is **smarter** than `tsc --watch` or `nodemon` which don't understand cross-service dependencies.

## Troubleshooting

### "fswatch: command not found"
Install fswatch (see Prerequisites above).

### "gaffer-exec: command not found"
Install gaffer-exec or ensure it's in your PATH.

### Watcher not detecting changes
- Verify file patterns in watch script
- Check you're editing the right directory
- Try adding `--verbose` to fswatch command

### Build errors
- Check error output from gaffer-exec
- Fix the code error
- Save file again to trigger rebuild

### Port already in use
- Kill existing process: `lsof -ti:4000 | xargs kill`
- Or use different port in server.ts

## Next Steps

- Read [README.md](README.md) for detailed explanation
- Read [ARCHITECTURE.md](ARCHITECTURE.md) for technical details
- Modify graph.json to add custom tasks
- Create watch scripts for new services
- Integrate with your IDE

## Summary

You now have a powerful development workflow:

| What | How |
|------|-----|
| **File watching** | fswatch (fast, native) |
| **Task orchestration** | gaffer-exec (smart, cached) |
| **Dependency cascade** | Automatic via graph.json |
| **Debouncing** | Built-in (--latency 0.5) |
| **Multi-service** | Three parallel watchers |

Enjoy fast, intelligent rebuilds! 🚀

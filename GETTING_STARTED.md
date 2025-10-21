# 🎯 Getting Started with CSV Processing

This quick guide will help you get the CSV processing system up and running in less than 5 minutes!

## ⚡ Super Quick Start

```bash
# 1. Start the system
./start-csv-system.sh

# 2. Open your browser
# Go to http://localhost:3000

# 3. Upload and process a CSV file
# Use the sample-data.csv file provided
```

That's it! 🎉

## 📁 What You Get

After following the quick start, you'll have:

1. **Backend Server** running on http://localhost:3001
   - MCP compliant API
   - CSV upload and processing
   - Data validation

2. **Frontend Interface** on http://localhost:3000
   - Drag-and-drop file upload
   - Real-time processing
   - Data visualization

3. **Rust Module** for high-performance CSV processing

## 🔍 Test the System

Run the comprehensive integration test:

```bash
./test-integration.sh
```

This tests all components automatically.

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [CSV_PROCESSING.md](CSV_PROCESSING.md) | Complete feature documentation |
| [QUICK_REFERENCE.md](QUICK_REFERENCE.md) | API endpoints and examples |
| [ARCHITECTURE.md](ARCHITECTURE.md) | System design and architecture |

## 🛠️ Manual Setup

If you prefer to start services manually:

### Backend
```bash
cd backend
npm install
npm start
```

### Frontend
```bash
cd frontend
npm install
npm start
```

## 🧪 Example Usage

### Upload a CSV file via API
```bash
curl -X POST http://localhost:3001/mcp/csv/upload \
  -F "file=@sample-data.csv"
```

### Process the file
```bash
curl -X POST http://localhost:3001/mcp/csv/:fileId/process
```

### List all files
```bash
curl http://localhost:3001/mcp/csv/list
```

## 💡 Sample CSV Format

```csv
id,name,value,timestamp
1,Item 1,100,2024-01-01T10:00:00Z
2,Item 2,200,2024-01-02T11:30:00Z
```

## 🚀 Features

- ✅ CSV file upload with drag-and-drop
- ✅ Data validation and transformation
- ✅ Real-time processing feedback
- ✅ MCP protocol compliant backend
- ✅ RESTful API
- ✅ Responsive web interface
- ✅ File management (view, delete)
- ✅ Error reporting

## 🆘 Troubleshooting

**Backend won't start?**
- Check if port 3001 is free: `lsof -i :3001`
- Ensure Node.js is installed: `node --version`

**Can't upload files?**
- Verify backend is running: `curl http://localhost:3001/mcp/health`
- Check file is valid CSV format

**Frontend shows "offline"?**
- Make sure backend is running first
- Check browser console for errors

## 📝 Next Steps

1. ✅ Start the system
2. ✅ Upload sample-data.csv
3. ✅ View processed results
4. Read [CSV_PROCESSING.md](CSV_PROCESSING.md) for advanced features
5. Check [ARCHITECTURE.md](ARCHITECTURE.md) for system details

## 🤝 Need Help?

- Check the [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for API details
- Run `./test-integration.sh` to verify setup
- Review logs in the terminal where servers are running

---

**Made with ❤️ for the Solana Verifiable Build project**

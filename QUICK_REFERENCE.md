# Quick Reference Guide - CSV Processing System

## 🚀 Quick Start

### Option 1: Automated Start (Recommended)
```bash
./start-csv-system.sh
```

### Option 2: Manual Start

**Terminal 1 - Backend:**
```bash
cd backend
npm install    # First time only
npm start
```

**Terminal 2 - Frontend:**
```bash
cd frontend
npm install    # First time only
npm start
```

## 📋 System Overview

### Components
1. **Rust CSV Processor** (`src/csv_processor.rs`)
   - High-performance CSV parsing
   - Data validation and transformation
   - Tested with unit tests

2. **MCP Backend** (`backend/`)
   - Node.js Express server
   - Port: 3001
   - MCP protocol compliant
   - RESTful API

3. **Web Frontend** (`frontend/`)
   - HTML5/JavaScript
   - Port: 3000
   - Responsive design
   - Real-time updates

## 🔗 URLs

| Service | URL | Description |
|---------|-----|-------------|
| Frontend | http://localhost:3000 | Web interface |
| Backend | http://localhost:3001 | API server |
| Health Check | http://localhost:3001/mcp/health | Server status |
| Capabilities | http://localhost:3001/mcp/capabilities | API info |

## 📝 Sample Usage

### Using the Web Interface

1. **Open Browser**: Navigate to http://localhost:3000
2. **Upload CSV**: Drag & drop or click to select `sample-data.csv`
3. **Process**: Click "Upload & Process"
4. **View Results**: See processed data in the file list
5. **Manage Files**: View, download, or delete files

### Using cURL

**Upload a file:**
```bash
curl -X POST http://localhost:3001/mcp/csv/upload \
  -F "file=@sample-data.csv"
```

**List files:**
```bash
curl http://localhost:3001/mcp/csv/list
```

**Get file data:**
```bash
curl http://localhost:3001/mcp/csv/<file-id>
```

**Process a file:**
```bash
curl -X POST http://localhost:3001/mcp/csv/<file-id>/process
```

**Delete a file:**
```bash
curl -X DELETE http://localhost:3001/mcp/csv/<file-id>
```

## 🧪 Testing

### Test the Rust Module
```bash
cargo test csv_processor
```

### Test Backend Endpoints
```bash
# Health check
curl http://localhost:3001/mcp/health

# Capabilities
curl http://localhost:3001/mcp/capabilities

# Upload test
curl -X POST http://localhost:3001/mcp/csv/upload \
  -F "file=@sample-data.csv"
```

## 📊 CSV Format

**Required columns:**
- `id`: Unique identifier
- `name`: Item name

**Optional columns:**
- `value`: Numeric or string value
- `timestamp`: Date/time (ISO format recommended)

**Example:**
```csv
id,name,value,timestamp
1,Item 1,100,2024-01-01T10:00:00Z
2,Item 2,200,2024-01-02T11:30:00Z
```

## 🛠️ Development

### Project Structure
```
├── src/
│   └── csv_processor.rs          # Rust CSV module
├── backend/
│   ├── src/index.js              # MCP server
│   ├── uploads/                  # Uploaded files (auto-created)
│   └── package.json
├── frontend/
│   ├── public/index.html         # Web UI
│   ├── src/server.js             # Static server
│   └── package.json
├── CSV_PROCESSING.md             # Full documentation
└── start-csv-system.sh           # Startup script
```

### Building
```bash
# Build Rust components
cargo build

# Install Node.js dependencies
cd backend && npm install && cd ..
cd frontend && npm install && cd ..
```

### Running Tests
```bash
# Rust tests
cargo test

# Check formatting
cargo fmt --check

# Linting
cargo clippy
```

## 🔧 Configuration

### Environment Variables

**Backend (.env):**
```env
PORT=3001
MAX_FILE_SIZE=10485760  # 10MB in bytes
```

**Frontend (.env):**
```env
PORT=3000
API_BASE_URL=http://localhost:3001
```

## 🐛 Troubleshooting

### Port Already in Use
```bash
# Find process using port 3001
lsof -i :3001
# Kill the process
kill -9 <PID>
```

### Backend Connection Failed
- Ensure backend is running: `curl http://localhost:3001/mcp/health`
- Check firewall settings
- Verify correct API_BASE_URL in frontend

### CSV Upload Fails
- Check file format (must be .csv)
- Ensure required columns exist
- Verify file size (< 10MB default)

### Dependencies Issue
```bash
# Clean and reinstall
cd backend && rm -rf node_modules && npm install
cd frontend && rm -rf node_modules && npm install
```

## 📚 Additional Resources

- **Full Documentation**: [CSV_PROCESSING.md](CSV_PROCESSING.md)
- **Main README**: [README.md](README.md)
- **Sample Data**: [sample-data.csv](sample-data.csv)

## 🎯 Features

✅ Drag-and-drop file upload
✅ Real-time processing status
✅ Data validation
✅ Error reporting
✅ File management (list, view, delete)
✅ MCP protocol compliant
✅ RESTful API
✅ Responsive UI
✅ CORS enabled
✅ Multi-file support

## 🔒 Security Notes

⚠️ **This is a development setup. For production:**
- Add authentication
- Implement rate limiting
- Use HTTPS
- Add input sanitization
- Implement proper CORS
- Add file size limits
- Scan for malware
- Use environment variables

## 💡 Tips

1. Use the sample CSV file to test: `sample-data.csv`
2. Check backend health before uploading: http://localhost:3001/mcp/health
3. Browser console shows detailed errors
4. Uploaded files are stored in `backend/uploads/`
5. Processed files have `processed-` prefix

---

**Need Help?** See [CSV_PROCESSING.md](CSV_PROCESSING.md) for detailed documentation.

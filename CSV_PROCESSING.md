# CSV Processing Feature

This repository now includes a comprehensive CSV processing system with an MCP (Model Context Protocol) backend and a web-based frontend.

## Features

### 🔹 CSV Processor (Rust)
- Located in `src/csv_processor.rs`
- Parse and process CSV files
- Validate data integrity
- Transform and clean data
- Export processed results

### 🔹 MCP Backend (Node.js)
- RESTful API following MCP protocol specifications
- File upload with validation
- CSV parsing and processing
- Data validation and transformation
- File management (list, view, delete)

### 🔹 Web Frontend
- Modern, responsive UI
- Drag-and-drop file upload
- Real-time processing status
- Data visualization in tables
- File management interface

## Architecture

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   Frontend  │  HTTP   │ MCP Backend  │  Uses   │ Rust CSV    │
│  (Port 3000)├────────►│ (Port 3001)  ├────────►│ Processor   │
│   HTML/JS   │         │   Node.js    │         │   Module    │
└─────────────┘         └──────────────┘         └─────────────┘
```

## Quick Start

### 1. Install Dependencies

#### Backend
```bash
cd backend
npm install
```

#### Frontend
```bash
cd frontend
npm install
```

#### Rust (if not already installed)
```bash
cargo build
```

### 2. Start the Servers

#### Terminal 1 - Start Backend (MCP Server)
```bash
cd backend
npm start
# Backend will run on http://localhost:3001
```

#### Terminal 2 - Start Frontend
```bash
cd frontend
npm start
# Frontend will run on http://localhost:3000
```

### 3. Access the Application

Open your browser and navigate to: **http://localhost:3000**

## API Endpoints (MCP Backend)

### Health Check
```
GET /mcp/health
```
Returns server status and protocol information.

### Get Capabilities
```
GET /mcp/capabilities
```
Returns available features and endpoints.

### Upload CSV
```
POST /mcp/csv/upload
Content-Type: multipart/form-data

Body: { file: <csv-file> }
```

### List Files
```
GET /mcp/csv/list
```

### Get File Data
```
GET /mcp/csv/:id
```

### Process CSV
```
POST /mcp/csv/:id/process
```

### Delete File
```
DELETE /mcp/csv/:id
```

## CSV Format

The system expects CSV files with the following structure:

```csv
id,name,value,timestamp
1,Item 1,100,2024-01-01
2,Item 2,200,2024-01-02
```

**Required fields:**
- `id`: Unique identifier
- `name`: Item name

**Optional fields:**
- `value`: Numeric or string value
- `timestamp`: Date/time information

## Usage Examples

### Using the Web Interface

1. **Upload a CSV file:**
   - Drag and drop your CSV file onto the upload area
   - Or click "Choose File" to browse

2. **Process the file:**
   - Click "Upload & Process"
   - View processing results and any errors

3. **View uploaded files:**
   - Click "Refresh List" to see all files
   - Click "View" to see file contents
   - Click "Delete" to remove a file

### Using the API (cURL Examples)

#### Upload and process a file:
```bash
curl -X POST http://localhost:3001/mcp/csv/upload \
  -F "file=@your-data.csv"
```

#### List all files:
```bash
curl http://localhost:3001/mcp/csv/list
```

#### View file data:
```bash
curl http://localhost:3001/mcp/csv/:fileId
```

#### Process a file:
```bash
curl -X POST http://localhost:3001/mcp/csv/:fileId/process
```

#### Delete a file:
```bash
curl -X DELETE http://localhost:3001/mcp/csv/:fileId
```

## Development

### Run Tests

#### Rust tests:
```bash
cargo test csv_processor
```

#### Backend dev mode (with auto-reload):
```bash
cd backend
npm run dev
```

#### Frontend dev mode (with auto-reload):
```bash
cd frontend
npm run dev
```

## Configuration

### Environment Variables

**Backend (backend/.env):**
```
PORT=3001
```

**Frontend (frontend/.env):**
```
PORT=3000
API_BASE_URL=http://localhost:3001
```

## File Structure

```
├── src/
│   └── csv_processor.rs      # Rust CSV processing module
├── backend/
│   ├── src/
│   │   └── index.js          # MCP backend server
│   ├── uploads/              # Uploaded CSV files (created automatically)
│   └── package.json
├── frontend/
│   ├── public/
│   │   └── index.html        # Web interface
│   ├── src/
│   │   └── server.js         # Frontend server
│   └── package.json
└── CSV_PROCESSING.md         # This file
```

## Security Notes

⚠️ **For Production Use:**

1. Add authentication and authorization
2. Implement rate limiting
3. Add input validation and sanitization
4. Use HTTPS
5. Implement CORS properly
6. Add file size limits
7. Scan uploaded files for malware
8. Use environment variables for configuration

## Troubleshooting

### Backend won't start
- Check if port 3001 is already in use
- Ensure Node.js version is 18 or higher
- Try `npm install` again

### Frontend can't connect to backend
- Verify backend is running on port 3001
- Check browser console for CORS errors
- Ensure API_BASE_URL is correct

### CSV upload fails
- Verify file is a valid CSV format
- Check file size (default limit: 10MB)
- Ensure required columns are present

## Contributing

When adding new features:
1. Update API documentation
2. Add tests
3. Update this README
4. Follow existing code style

## License

MIT License - see LICENSE file for details

# Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          User Browser                            │
│                     http://localhost:3000                        │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                               │ HTTP Requests
                               │
┌──────────────────────────────▼──────────────────────────────────┐
│                    Frontend Server (Node.js)                     │
│                         Port: 3000                               │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Static File Server                                         │ │
│  │  - Serves index.html                                        │ │
│  │  - Handles routing                                          │ │
│  └────────────────────────────────────────────────────────────┘ │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                               │ AJAX/Fetch API
                               │
┌──────────────────────────────▼──────────────────────────────────┐
│              MCP Backend Server (Node.js/Express)                │
│                         Port: 3001                               │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  REST API Endpoints (MCP Protocol)                          │ │
│  │  - GET  /mcp/health                                         │ │
│  │  - GET  /mcp/capabilities                                   │ │
│  │  - POST /mcp/csv/upload                                     │ │
│  │  - GET  /mcp/csv/list                                       │ │
│  │  - GET  /mcp/csv/:id                                        │ │
│  │  - POST /mcp/csv/:id/process                                │ │
│  │  - DELETE /mcp/csv/:id                                      │ │
│  └────────────────────────────────────────────────────────────┘ │
│                               │                                  │
│  ┌────────────────────────────▼────────────────────────────────┐ │
│  │  Middleware Layer                                            │ │
│  │  - CORS handling                                             │ │
│  │  - Multer file upload                                        │ │
│  │  - Express JSON parser                                       │ │
│  │  - Error handling                                            │ │
│  └────────────────────────────┬────────────────────────────────┘ │
│                               │                                  │
│  ┌────────────────────────────▼────────────────────────────────┐ │
│  │  CSV Processing Layer                                        │ │
│  │  - csv-parser: Read CSV files                               │ │
│  │  - csv-writer: Write processed CSV                          │ │
│  │  - Data validation                                           │ │
│  │  - Data transformation                                       │ │
│  └────────────────────────────┬────────────────────────────────┘ │
└────────────────────────────────┼────────────────────────────────┘
                                │
                                │ Can integrate with
                                │
┌────────────────────────────────▼────────────────────────────────┐
│              Rust CSV Processor (Optional)                       │
│                   src/csv_processor.rs                           │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  High-Performance Processing                                │ │
│  │  - CsvProcessor struct                                       │ │
│  │  - read_csv()                                                │ │
│  │  - write_csv()                                               │ │
│  │  - process()                                                 │ │
│  │  - validate_csv()                                            │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘

                                │
                                │ Stores files in
                                ▼
                    ┌─────────────────────┐
                    │  File System        │
                    │  backend/uploads/   │
                    └─────────────────────┘
```

## Data Flow

### Upload and Process Flow

```
User Action                Backend Processing                File System
────────────                ──────────────────                ───────────

1. Select CSV ──────────────────────────────────────────────────────────┐
   file                                                                  │
                                                                         │
2. Upload ──────────────> POST /mcp/csv/upload                          │
   request                  │                                            │
                           │                                            │
                           ├─> Multer validation                        │
                           │   (file type, size)                        │
                           │                                            │
                           ├─> Save to uploads/ ──────────────────────>│
                           │                                            │
                           └─> Return file metadata                     │
                                                                         │
3. Receive                                                              │
   file ID ◄────────────────────────────────────────────────────────────┘
                                                                         
4. Process ──────────────> POST /mcp/csv/:id/process                    
   request                  │                                            
                           │                                            
                           ├─> Read CSV from uploads/ ◄─────────────────┤
                           │                                            │
                           ├─> Parse with csv-parser                    │
                           │   (stream-based)                           │
                           │                                            │
                           ├─> Validate each row                        │
                           │   - Check required fields                  │
                           │   - Trim whitespace                        │
                           │   - Collect errors                         │
                           │                                            │
                           ├─> Transform data                           │
                           │   - Clean values                           │
                           │   - Add timestamps                         │
                           │                                            │
                           ├─> Write processed CSV ────────────────────>│
                           │   (processed-*.csv)                        │
                           │                                            │
                           └─> Return processing results                │
                                                                         
5. View results ◄────────────────────────────────────────────────────────┘
```

### View Data Flow

```
User Request               Backend Processing                File System
────────────               ──────────────────                ───────────

1. Click View ──────────> GET /mcp/csv/:id
                            │
                            ├─> Find file in uploads/ ◄──────────────┤
                            │                                         │
                            ├─> Stream read CSV                       │
                            │                                         │
                            ├─> Parse with csv-parser                 │
                            │                                         │
                            ├─> Collect all records                   │
                            │                                         │
                            └─> Return JSON with records              │

2. Display ◄───────────────────────────────────────────────────────────┘
   in table
```

## Component Responsibilities

### Frontend (HTML/JavaScript)
- **UI Rendering**: Display interface elements
- **User Interaction**: Handle clicks, drag-and-drop
- **API Communication**: Send HTTP requests to backend
- **Data Visualization**: Show CSV data in tables
- **State Management**: Track uploaded files, selection
- **Error Display**: Show validation errors to user

### Backend (Node.js/Express)
- **HTTP Server**: Handle incoming requests
- **Routing**: Direct requests to appropriate handlers
- **File Management**: Upload, store, retrieve, delete files
- **CSV Processing**: Parse, validate, transform data
- **Error Handling**: Catch and format errors
- **CORS**: Enable cross-origin requests
- **Response Formatting**: Structure JSON responses

### Rust Module (Optional Integration)
- **High Performance**: Process large CSV files quickly
- **Type Safety**: Strongly typed data structures
- **Memory Efficiency**: Minimal memory footprint
- **Validation**: Complex business logic validation
- **Testing**: Comprehensive unit test coverage

## MCP Protocol Compliance

### Protocol Specifications

The backend follows Model Context Protocol (MCP) standards:

1. **Health Endpoint**: `/mcp/health`
   - Returns server status
   - Protocol version
   - Service identification

2. **Capabilities Endpoint**: `/mcp/capabilities`
   - Lists available features
   - Describes endpoints
   - Version information

3. **Resource Endpoints**: `/mcp/csv/*`
   - Standard CRUD operations
   - Consistent error responses
   - Proper HTTP status codes

4. **Response Format**:
   ```json
   {
     "success": true,
     "data": { /* response data */ },
     "error": null
   }
   ```

## Security Layers

```
┌─────────────────────────────────────────────────────────┐
│ Layer 1: Client-Side Validation                         │
│  - File type checking (.csv only)                       │
│  - UI feedback                                          │
└──────────────────┬──────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────────┐
│ Layer 2: Transport Security (Future)                    │
│  - HTTPS encryption                                     │
│  - CORS configuration                                   │
└──────────────────┬──────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────────┐
│ Layer 3: Backend Validation                             │
│  - Multer file filter                                   │
│  - File size limits                                     │
│  - MIME type validation                                 │
└──────────────────┬──────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────────┐
│ Layer 4: Data Validation                                │
│  - CSV structure validation                             │
│  - Required field checking                              │
│  - Data type validation                                 │
└──────────────────┬──────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────────┐
│ Layer 5: Error Handling                                 │
│  - Try-catch blocks                                     │
│  - Proper error messages                                │
│  - Logging (future)                                     │
└─────────────────────────────────────────────────────────┘
```

## Scalability Considerations

### Current Implementation (Development)
- Single instance
- File system storage
- In-memory processing
- No authentication

### Production Recommendations

1. **Horizontal Scaling**
   - Load balancer
   - Multiple backend instances
   - Shared file storage (S3, NFS)

2. **Database Integration**
   - Store file metadata
   - Track processing status
   - User management

3. **Message Queue**
   - Async processing
   - Handle large files
   - Job queuing

4. **Caching**
   - Redis for session data
   - Processed results cache
   - API response cache

5. **Monitoring**
   - Health checks
   - Performance metrics
   - Error tracking
   - Log aggregation

## Technology Stack

### Frontend
- **HTML5**: Structure
- **CSS3**: Styling (inline for simplicity)
- **JavaScript (ES6+)**: Logic and API calls
- **Fetch API**: HTTP requests

### Backend
- **Node.js**: Runtime environment
- **Express.js**: Web framework
- **Multer**: File upload handling
- **csv-parser**: CSV reading
- **csv-writer**: CSV writing
- **CORS**: Cross-origin support

### Rust Module
- **csv crate**: CSV parsing
- **serde**: Serialization
- **anyhow**: Error handling
- **tempfile**: Testing

## File Structure

```
solana-verifiable-build/
│
├── src/
│   ├── main.rs              # Main Rust application
│   ├── csv_processor.rs     # CSV processing module
│   ├── api/                 # Existing API code
│   └── ...
│
├── backend/
│   ├── src/
│   │   └── index.js         # MCP backend server
│   ├── uploads/             # Uploaded CSV files (gitignored)
│   ├── package.json
│   └── node_modules/        # Dependencies (gitignored)
│
├── frontend/
│   ├── public/
│   │   └── index.html       # Web interface
│   ├── src/
│   │   └── server.js        # Static file server
│   ├── package.json
│   └── node_modules/        # Dependencies (gitignored)
│
├── CSV_PROCESSING.md        # Full documentation
├── QUICK_REFERENCE.md       # Quick start guide
├── ARCHITECTURE.md          # This file
├── sample-data.csv          # Test data
└── start-csv-system.sh      # Startup script
```

## Future Enhancements

1. **Authentication & Authorization**
   - User registration/login
   - JWT tokens
   - Role-based access

2. **Advanced Processing**
   - Data aggregation
   - Statistical analysis
   - Data visualization charts

3. **Export Formats**
   - JSON export
   - Excel export
   - PDF reports

4. **Real-time Updates**
   - WebSocket support
   - Progress tracking
   - Live notifications

5. **Batch Processing**
   - Multiple file upload
   - Scheduled processing
   - Background jobs

6. **Integration**
   - Webhook support
   - External API integration
   - Cloud storage (S3, GCS)

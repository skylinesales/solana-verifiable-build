import express from 'express';
import cors from 'cors';
import multer from 'multer';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import csvParser from 'csv-parser';
import { createObjectCsvWriter } from 'csv-writer';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3001;

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = path.join(__dirname, '..', 'uploads');
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  }
});

const upload = multer({ 
  storage,
  fileFilter: (req, file, cb) => {
    if (file.mimetype === 'text/csv' || file.originalname.endsWith('.csv')) {
      cb(null, true);
    } else {
      cb(new Error('Only CSV files are allowed'));
    }
  }
});

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// MCP Protocol Routes
app.get('/mcp/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    protocol: 'MCP',
    service: 'solana-verify-csv-processor',
    timestamp: new Date().toISOString()
  });
});

app.get('/mcp/capabilities', (req, res) => {
  res.json({
    protocol_version: '1.0',
    capabilities: {
      csv_processing: true,
      file_upload: true,
      data_validation: true,
      data_transformation: true
    },
    endpoints: [
      { method: 'POST', path: '/mcp/csv/upload', description: 'Upload CSV file' },
      { method: 'GET', path: '/mcp/csv/list', description: 'List uploaded CSV files' },
      { method: 'GET', path: '/mcp/csv/:id', description: 'Get CSV file data' },
      { method: 'POST', path: '/mcp/csv/:id/process', description: 'Process CSV file' },
      { method: 'DELETE', path: '/mcp/csv/:id', description: 'Delete CSV file' }
    ]
  });
});

// CSV Upload
app.post('/mcp/csv/upload', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    const fileInfo = {
      id: path.basename(req.file.filename, '.csv'),
      filename: req.file.originalname,
      path: req.file.path,
      size: req.file.size,
      uploadedAt: new Date().toISOString()
    };

    res.json({
      success: true,
      message: 'File uploaded successfully',
      data: fileInfo
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// List uploaded CSV files
app.get('/mcp/csv/list', (req, res) => {
  try {
    const uploadDir = path.join(__dirname, '..', 'uploads');
    if (!fs.existsSync(uploadDir)) {
      return res.json({ files: [] });
    }

    const files = fs.readdirSync(uploadDir)
      .filter(file => file.endsWith('.csv'))
      .map(file => {
        const filePath = path.join(uploadDir, file);
        const stats = fs.statSync(filePath);
        return {
          id: path.basename(file, '.csv'),
          filename: file,
          size: stats.size,
          createdAt: stats.birthtime.toISOString()
        };
      });

    res.json({ files });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get CSV file data
app.get('/mcp/csv/:id', async (req, res) => {
  try {
    const uploadDir = path.join(__dirname, '..', 'uploads');
    const files = fs.readdirSync(uploadDir).filter(f => f.startsWith(req.params.id));
    
    if (files.length === 0) {
      return res.status(404).json({ error: 'File not found' });
    }

    const filePath = path.join(uploadDir, files[0]);
    const records = [];

    fs.createReadStream(filePath)
      .pipe(csvParser())
      .on('data', (data) => records.push(data))
      .on('end', () => {
        res.json({
          success: true,
          data: {
            id: req.params.id,
            filename: files[0],
            recordCount: records.length,
            records
          }
        });
      })
      .on('error', (error) => {
        res.status(500).json({ error: error.message });
      });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Process CSV file
app.post('/mcp/csv/:id/process', async (req, res) => {
  try {
    const uploadDir = path.join(__dirname, '..', 'uploads');
    const files = fs.readdirSync(uploadDir).filter(f => f.startsWith(req.params.id));
    
    if (files.length === 0) {
      return res.status(404).json({ error: 'File not found' });
    }

    const filePath = path.join(uploadDir, files[0]);
    const records = [];
    const errors = [];

    fs.createReadStream(filePath)
      .pipe(csvParser())
      .on('data', (data) => {
        // Validate and process each record
        if (!data.id || !data.name) {
          errors.push({ row: records.length + 1, error: 'Missing required fields: id or name' });
        } else {
          // Transform data (trim whitespace, etc.)
          const processedRecord = {
            id: data.id.trim(),
            name: data.name.trim(),
            value: data.value ? data.value.trim() : '',
            timestamp: data.timestamp || new Date().toISOString()
          };
          records.push(processedRecord);
        }
      })
      .on('end', async () => {
        // Optionally save processed data
        const outputPath = path.join(uploadDir, `processed-${files[0]}`);
        
        if (records.length > 0) {
          const csvWriter = createObjectCsvWriter({
            path: outputPath,
            header: [
              { id: 'id', title: 'ID' },
              { id: 'name', title: 'NAME' },
              { id: 'value', title: 'VALUE' },
              { id: 'timestamp', title: 'TIMESTAMP' }
            ]
          });

          await csvWriter.writeRecords(records);
        }

        res.json({
          success: true,
          data: {
            totalRecords: records.length + errors.length,
            processedRecords: records.length,
            errors,
            outputFile: `processed-${files[0]}`
          }
        });
      })
      .on('error', (error) => {
        res.status(500).json({ error: error.message });
      });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Delete CSV file
app.delete('/mcp/csv/:id', (req, res) => {
  try {
    const uploadDir = path.join(__dirname, '..', 'uploads');
    const files = fs.readdirSync(uploadDir).filter(f => f.startsWith(req.params.id));
    
    if (files.length === 0) {
      return res.status(404).json({ error: 'File not found' });
    }

    files.forEach(file => {
      fs.unlinkSync(path.join(uploadDir, file));
    });

    res.json({
      success: true,
      message: 'File deleted successfully'
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: err.message });
});

app.listen(PORT, () => {
  console.log(`MCP Backend server running on http://localhost:${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/mcp/health`);
  console.log(`Capabilities: http://localhost:${PORT}/mcp/capabilities`);
});

use anyhow::{anyhow, Result};
use csv::{Reader, Writer};
use serde::{Deserialize, Serialize};
use std::fs::File;
use std::path::Path;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct CsvRecord {
    pub id: String,
    pub name: String,
    pub value: String,
    pub timestamp: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ProcessResult {
    pub total_records: usize,
    pub processed_records: usize,
    pub errors: Vec<String>,
}

pub struct CsvProcessor {
    input_path: String,
    output_path: Option<String>,
}

impl CsvProcessor {
    pub fn new(input_path: String) -> Self {
        CsvProcessor {
            input_path,
            output_path: None,
        }
    }

    pub fn with_output(mut self, output_path: String) -> Self {
        self.output_path = Some(output_path);
        self
    }

    pub fn read_csv(&self) -> Result<Vec<CsvRecord>> {
        let path = Path::new(&self.input_path);
        if !path.exists() {
            return Err(anyhow!("CSV file not found: {}", self.input_path));
        }

        let file = File::open(path)?;
        let mut reader = Reader::from_reader(file);
        let mut records = Vec::new();

        for result in reader.deserialize() {
            match result {
                Ok(record) => records.push(record),
                Err(e) => eprintln!("Error reading record: {}", e),
            }
        }

        Ok(records)
    }

    pub fn write_csv(&self, records: &[CsvRecord]) -> Result<()> {
        let output_path = self
            .output_path
            .as_ref()
            .ok_or_else(|| anyhow!("Output path not set"))?;

        let file = File::create(output_path)?;
        let mut writer = Writer::from_writer(file);

        for record in records {
            writer.serialize(record)?;
        }

        writer.flush()?;
        Ok(())
    }

    pub fn process(&self) -> Result<ProcessResult> {
        let records = self.read_csv()?;
        let total_records = records.len();
        let mut errors = Vec::new();

        // Process records (example: validate and transform)
        let processed_records: Vec<CsvRecord> = records
            .into_iter()
            .filter_map(|mut record| {
                if record.id.is_empty() {
                    errors.push(format!("Record with empty id: {:?}", record.name));
                    return None;
                }
                // Transform data if needed
                record.value = record.value.trim().to_string();
                Some(record)
            })
            .collect();

        let processed_count = processed_records.len();

        // Write output if path is set
        if self.output_path.is_some() {
            self.write_csv(&processed_records)?;
        }

        Ok(ProcessResult {
            total_records,
            processed_records: processed_count,
            errors,
        })
    }

    pub fn validate_csv(&self) -> Result<bool> {
        let records = self.read_csv()?;
        
        for record in records {
            if record.id.is_empty() || record.name.is_empty() {
                return Ok(false);
            }
        }
        
        Ok(true)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::Write;
    use tempfile::NamedTempFile;

    #[test]
    fn test_csv_processor_read() -> Result<()> {
        let mut temp_file = NamedTempFile::new()?;
        writeln!(
            temp_file,
            "id,name,value,timestamp\n1,test,100,2024-01-01"
        )?;
        temp_file.flush()?;

        let processor = CsvProcessor::new(temp_file.path().to_str().unwrap().to_string());
        let records = processor.read_csv()?;

        assert_eq!(records.len(), 1);
        assert_eq!(records[0].id, "1");
        assert_eq!(records[0].name, "test");

        Ok(())
    }
}

use std::fs;
use std::io::ErrorKind;
use std::path::{Path, PathBuf};

use anyhow::{Context, Result};

use crate::model::WidgetData;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum WriteOutcome {
    Updated,
    Unchanged,
}

pub fn read_widget_data(path: &Path) -> Result<Option<WidgetData>> {
    match fs::read(path) {
        Ok(bytes) => {
            let data = serde_json::from_slice(&bytes).with_context(|| {
                format!("failed to parse existing widget data at {}", path.display())
            })?;

            Ok(Some(data))
        }
        Err(error) if error.kind() == ErrorKind::NotFound => Ok(None),
        Err(error) => {
            Err(error).with_context(|| format!("failed to read widget data at {}", path.display()))
        }
    }
}

pub fn write_widget_data(path: &Path, data: &WidgetData) -> Result<WriteOutcome> {
    let mut payload = serde_json::to_vec(data).context("failed to serialize widget data")?;
    payload.push(b'\n');

    if let Ok(existing) = fs::read(path) {
        if existing == payload {
            return Ok(WriteOutcome::Unchanged);
        }
    }

    let parent = path
        .parent()
        .context("widget data path is missing a parent directory")?;
    fs::create_dir_all(parent).with_context(|| {
        format!(
            "failed to create widget data directory {}",
            parent.display()
        )
    })?;

    let temporary_path = temp_path_for(path)?;
    fs::write(&temporary_path, &payload).with_context(|| {
        format!(
            "failed to write temporary widget data to {}",
            temporary_path.display()
        )
    })?;
    fs::rename(&temporary_path, path).with_context(|| {
        format!(
            "failed to atomically replace widget data file {} with {}",
            path.display(),
            temporary_path.display()
        )
    })?;

    Ok(WriteOutcome::Updated)
}

fn temp_path_for(path: &Path) -> Result<PathBuf> {
    let file_name = path
        .file_name()
        .and_then(|name| name.to_str())
        .context("widget data path must have a UTF-8 file name")?;

    Ok(path.with_file_name(format!(".{file_name}.tmp")))
}

import React from 'react';
import { Box, Typography, Button } from '@mui/material';

const Step2 = ({ config, setConfig, nextButton }) => {
  // Handler for input change
  const handleChange = (e) => {
    const { name, value } = e.target;
    setConfig((prev) => ({ ...prev, [name]: value }));
  };

  return (
    <Box sx={{ p: 4 }}>
      <Typography variant="h6" align="center" style={{ color: '#fff', marginBottom: 16 }}>Storage Config</Typography>
      <Typography style={{ color: '#fff', marginBottom: 8 }}>Where would you like to store your media and config?</Typography>
      <Box display="flex" gap={2} alignItems="center">
        <input
          type="text"
          name="storagePath"
          placeholder="/mnt/media or /home/user/SurgeData"
          value={config.storagePath}
          onChange={handleChange}
          style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
        />
        <Button
          variant="outlined"
          style={{ color: '#fff', borderColor: '#fff', minWidth: 120 }}
          onClick={async () => {
            if (window.showDirectoryPicker) {
              try {
                const dirHandle = await window.showDirectoryPicker();
                setConfig((prev) => ({ ...prev, storagePath: dirHandle.name }));
              } catch (e) {
                // User cancelled or not supported
              }
            } else {
              alert('Directory picker is not supported in this browser. Please type the path manually.');
            }
          }}
        >
          Browse
        </Button>
      </Box>
      <Typography style={{ color: '#fff', background: '#232323', fontSize: 14, marginTop: 12, padding: 12, borderRadius: 4 }}>
        The storage path you set here will be treated as the main directory for your Surge stack. All service data, configuration, and volumes will be stored under this directory, just like in the setup script.
      </Typography>
      <Typography style={{ color: '#aaa', fontSize: 13, marginTop: 8 }}>
        You can type a path or use the Browse button (if supported by your browser).
      </Typography>
      {nextButton}
    </Box>
  );
};

export default Step2;

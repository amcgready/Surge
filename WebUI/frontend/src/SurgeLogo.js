import React from 'react';
import surgeLogo from './assets/Surge.png';

const SurgeLogo = () => (
  <div style={{ display: 'flex', justifyContent: 'center', marginTop: 32 }}>
    <img src={surgeLogo} alt="Surge Logo" style={{ maxWidth: 180, maxHeight: 180 }} />
  </div>
);

export default SurgeLogo;

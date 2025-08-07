
import React, { useEffect } from 'react';
import { Container, Typography, Box, Stepper, Step, StepLabel, Button, Tooltip, Divider } from '@mui/material';
import SurgeLogo from './SurgeLogo';
import bgImage from './assets/background.jpg';
import radarrLogo from './assets/service-logos/radarr.png';
import sonarrLogo from './assets/service-logos/sonarr.png';
import prowlarrLogo from './assets/service-logos/prowlarr.png';
import bazarrLogo from './assets/service-logos/bazarr.png';
import cinesyncLogo from './assets/service-logos/cinesync.png';
import placeholdarrLogo from './assets/service-logos/Placeholdarr.png';
import plexLogo from './assets/service-logos/plex.png';
import embyLogo from './assets/service-logos/emby.png';
import jellyfinLogo from './assets/service-logos/jellyfin.png';
import nzbgetLogo from './assets/service-logos/NZBGet.png';
import rdtClientLogo from './assets/service-logos/RDT-Client.png';
import gapsLogo from './assets/service-logos/gaps.jpg';
import zurgLogo from './assets/service-logos/zurg.png';
import decypharrLogo from './assets/service-logos/decypharr.png';

const steps = [
  'Welcome',
  'Media Server',
  'Storage Config',
  'External APIs',
  'Media Automation',
  'Download Tools',
  'Content Enhancement',
  'Monitoring & UI',
  'Shared Config',
  'Review',
  'Deploy'
];

function App() {
  // State for advanced config toggles for all services
  const [showRadarrAdvanced, setShowRadarrAdvanced] = React.useState(false);
  const [showSonarrAdvanced, setShowSonarrAdvanced] = React.useState(false);
  const [showProwlarrAdvanced, setShowProwlarrAdvanced] = React.useState(false);
  const [showBazarrAdvanced, setShowBazarrAdvanced] = React.useState(false);
  const [showKometaAdvanced, setShowKometaAdvanced] = React.useState(false);
  const [showPosterizarrAdvanced, setShowPosterizarrAdvanced] = React.useState(false);
  const [showPlaceholdarrAdvanced, setShowPlaceholdarrAdvanced] = React.useState(false);
  const [showNZBGetAdvanced, setShowNZBGetAdvanced] = React.useState(false);
  const [showRdtClientAdvanced, setShowRdtClientAdvanced] = React.useState(false);
  const [showGapsAdvanced, setShowGapsAdvanced] = React.useState(false);
  const [showCliDebridAdvanced, setShowCliDebridAdvanced] = React.useState(false);
  const [showImageMaidAdvanced, setShowImageMaidAdvanced] = React.useState(false);
  const [showCineSyncAdvanced, setShowCineSyncAdvanced] = React.useState(false); // Only used in CineSync section now
  const [showZurgAdvanced, setShowZurgAdvanced] = React.useState(false);
  const [showDecypharrAdvanced, setShowDecypharrAdvanced] = React.useState(false);
  const [showNoMediaServerDialog, setShowNoMediaServerDialog] = React.useState(false);
  // JSON parse error state
  const [jsonParseError, setJsonParseError] = React.useState('');
  // Monitoring & Interface toggles
  const monitoringList = [
    { key: 'overseerr', name: 'Overseerr', desc: 'Media request and management tool', logo: require('./assets/service-logos/overseerr.png') },
    { key: 'tautulli', name: 'Tautulli', desc: 'Plex monitoring and analytics', logo: require('./assets/service-logos/tautulli.png') },
    { key: 'homepage', name: 'Homepage', desc: 'Unified dashboard for your media server', logo: require('./assets/service-logos/homepage.png') }
  ];
  const [monitoring, setMonitoring] = React.useState({
    overseerr: true,
    tautulli: true,
    homepage: true
  });
  // Content Enhancement toggles
  const contentEnhancementList = [
    { key: 'kometa', name: 'Kometa', desc: 'Collection and metadata management for Plex/Emby/Jellyfin', logo: require('./assets/service-logos/kometa.png') },
    { key: 'posterizarr', name: 'Posterizarr', desc: 'Automated poster and artwork management', logo: require('./assets/service-logos/posterizarr.png') }
  ];
  const [contentEnhancement, setContentEnhancement] = React.useState({
    kometa: true,
    posterizarr: true
  });
  // Download Tools toggles

  const downloadToolsList = [
    { key: 'nzbget', name: 'NZBGet', desc: 'Efficient Usenet downloader', logo: nzbgetLogo },
    { key: 'rdtclient', name: 'RDT-Client', desc: 'Real-Debrid download client', logo: rdtClientLogo },
    { key: 'gaps', name: 'GAPS', desc: 'Finds missing movies for Radarr', logo: gapsLogo },
    { key: 'zurg', name: 'Zurg', desc: 'NZBGet/Usenet automation tool', logo: zurgLogo },
    { key: 'decypharr', name: 'Decypharr', desc: 'Decryption and post-processing tool', logo: decypharrLogo }
  ];
  const [downloadTools, setDownloadTools] = React.useState({
    nzbget: true,
    rdtclient: true,
    gaps: true,
    zurg: true,
    decypharr: true
  });
  // Core Media Server single-select toggle
  const coreServers = [
    { key: 'plex', name: 'Plex', logo: plexLogo, desc: 'Premium media streaming platform' },
    { key: 'emby', name: 'Emby', logo: embyLogo, desc: 'Feature-rich media server with live TV support' },
    { key: 'jellyfin', name: 'Jellyfin', logo: jellyfinLogo, desc: 'Free and open-source media server' }
  ];
  const [activeStep, setActiveStep] = React.useState(0);
  const [showProgress, setShowProgress] = React.useState(false);
  const [progress, setProgress] = React.useState(0);
  const [progressMessage, setProgressMessage] = React.useState('');
  const [timeEstimate, setTimeEstimate] = React.useState(0);

  const [mediaAutomation, setMediaAutomation] = React.useState({
    radarr: true,
    sonarr: true,
    prowlarr: true,
    bazarr: true,
    cinesync: true,
    placeholdarr: true
  });

  const defaultUrls = {
    radarr: 'http://radarr:7878',
    sonarr: 'http://sonarr:8989',
    prowlarr: 'http://prowlarr:9696',
    bazarr: 'http://bazarr:6767',
    cinesync: 'http://cinesync:8080',
    placeholdarr: 'http://placeholdarr:9090'
  };

  const serviceDescriptions = {
    radarr: 'Radarr: Movie collection manager for Usenet and BitTorrent',
    sonarr: 'Sonarr: TV series collection manager',
    prowlarr: 'Prowlarr: Indexer manager/proxy for torrent trackers and Usenet indexers',
    bazarr: 'Bazarr: Subtitle management for Radarr and Sonarr',
    cinesync: 'CineSync: Media library management for Movies & TV shows',
    placeholdarr: 'Placeholdarr: Creates placeholder files for undownloaded media'
  };

  const serviceLogos = {
    radarr: radarrLogo,
    sonarr: sonarrLogo,
    prowlarr: prowlarrLogo,
    bazarr: bazarrLogo,
    cinesync: cinesyncLogo,
    placeholdarr: placeholdarrLogo
  };

  const [config, setConfig] = React.useState({
    // Core Media Server
    mediaServer: '', // plex|emby|jellyfin
    // Storage Config
    storagePath: '',
    // Media Automation - Radarr settings
    radarrSettings: {
      port: 7878,
      sslPort: '',
      enableSsl: 'false',
      urlBase: '',
      apiKey: 'surgestack',
      rootFolderPath: '/data/movies',
      movieProfileId: '',
      minimumAvailability: 'released',
      authMethod: 'Basic',
      logLevel: 'Info',
      branch: 'master',
      launchBrowser: 'false',
      analyticsEnabled: 'false',
      updateAutomatically: 'true',
      updateMechanism: 'docker',
      logRotate: '',
      backupRetention: '',
      proxyEnabled: 'false',
      proxyType: 'http',
      proxyHostname: '',
      proxyPort: '',
      proxyUsername: '',
      proxyPassword: '',
      appData: '',
      configPath: '',
      // removed puid/pgid, now in shared config
      // removed umask/tz, now in shared config
    },
    // Media Automation - Sonarr settings
    sonarrSettings: {
      port: 8989,
      sslPort: '',
      enableSsl: 'false',
      urlBase: '',
      instanceName: '',
      apiKey: 'surgestack',
      rootFolderPath: '/data/tv',
      seriesProfileId: '',
      minimumAvailability: 'released',
      namingFormat: '',
      seasonFolderFormat: '',
      multiEpisodeStyle: '',
      createEmptyFolders: 'true',
      deleteEmptyFolders: 'true',
      useHardLinks: 'true',
      importExtraFiles: 'true',
      unmonitorDeleted: 'true',
      downloadPropers: 'prefer',
      analyseVideo: 'true',
      rescanAfterRefresh: 'always',
      changeFileDate: 'none',
      recyclingBinPath: '',
      recyclingBinRetention: '',
      setPermissions: 'false',
      chmodFolder: '',
      chownGroup: '',
      authMethod: 'Basic',
      logLevel: 'Info',
      branch: 'master',
      analyticsEnabled: 'false',
      updateAutomatically: 'true',
      updateMechanism: 'docker',
      appData: '',
      configPath: '',
      backupFolder: '',
      backupInterval: '',
      backupRetention: '',
      proxyEnabled: 'false',
      proxyType: 'http',
      proxyHostname: '',
      proxyPort: '',
      proxyUsername: '',
      proxyPassword: '',
      ignoredAddresses: '',
      bypassProxyLocal: 'true',
      logRotate: '',
      // removed puid/pgid, now in shared config
      // removed umask/tz, now in shared config
      launchBrowser: 'false',
    },
    // Media Automation - Prowlarr settings
    prowlarrSettings: {
      port: 9696,
      sslPort: '',
      enableSsl: 'false',
      urlBase: '',
      instanceName: '',
      apiKey: 'surgestack',
      appData: '',
      configPath: '',
      authMethod: 'Basic',
      certificateValidation: 'enabled',
      logLevel: 'Info',
      logRotate: '',
      branch: 'master',
      analyticsEnabled: 'false',
      updateAutomatically: 'true',
      updateMechanism: 'docker',
      updateScript: '',
      backupFolder: '',
      backupInterval: '',
      backupRetention: '',
      proxyEnabled: 'false',
      proxyType: 'http',
      proxyHostname: '',
      proxyPort: '',
      proxyUsername: '',
      proxyPassword: '',
      ignoredAddresses: '',
      bypassProxyLocal: 'true',
      // removed puid/pgid, now in shared config
      // removed umask/tz, now in shared config
      tags: '',
      launchBrowser: 'false',
    },
    // Media Automation - Bazarr settings
    bazarrSettings: {
      port: 6767,
      sslPort: '',
      enableSsl: 'false',
      urlBase: '',
      apiKey: 'surgestack',
      authMethod: 'Basic',
      logLevel: 'Info',
      branch: 'master',
      launchBrowser: 'false',
      appData: '',
      configPath: '',
      analyticsEnabled: 'false',
      updateAutomatically: 'false',
      updateMechanism: '',
      logRotate: '',
      backupRetention: '',
      proxyEnabled: 'false',
      proxyType: '',
      proxyHostname: '',
      proxyPort: '',
      proxyUsername: '',
      proxyPassword: '',
    },
    // Media Automation - CineSync settings
    cinesyncSettings: {
      webuiPort: 5173,
      apiPort: 8082,
      webdavPort: 8082,
      apiKey: 'surgestack',
      authMethod: 'Basic',
      logLevel: 'Info',
      branch: 'master',
      launchBrowser: 'false',
      sourceDir: '',
      useSourceStructure: false,
      cinesyncLayout: true,
      animeSeparation: true,
      fourKSeparation: true,
      kidsSeparation: false,
      customShowFolder: '',
      custom4kShowFolder: '',
      customAnimeShowFolder: '',
      customMovieFolder: '',
      custom4kMovieFolder: '',
      customAnimeMovieFolder: '',
      customKidsMovieFolder: '',
      customKidsShowFolder: '',
      showResolutionStructure: false,
      movieResolutionStructure: false,
      cinesyncIp: '0.0.0.0',
      cinesyncAuthEnabled: true,
      cinesyncUsername: 'admin',
      cinesyncPassword: 'admin',
      origin_directory: '/opt/surge/CineSync/Origin',
      destination_directory: '/opt/surge/CineSync/Destination',
      rcloneMount: false,
      mountCheckInterval: 30,
      tmdbApiKey: '',
      language: 'English',
      animeScan: false,
      tmdbFolderId: false,
      imdbFolderId: false,
      tvdbFolderId: false,
      renameEnabled: false,
      mediaInfoParser: false,
      renameTags: '',
      mediaInfoTags: '',
      movieCollectionEnabled: false,
      relativeSymlink: false,
      maxCores: 1,
      maxProcesses: 15,
      skipExtrasFolder: true,
      junkMaxSizeMb: 5,
      allowedExtensions: '.mp4,.mkv,.srt,.avi,.mov,.divx,.strm',
      skipAdultPatterns: true,
      sleepTime: 60,
      symlinkCleanupInterval: 600,
      enablePlexUpdate: false,
      plexUrl: '',
      plexToken: '',
      cinesyncIp: '0.0.0.0',
      cinesyncAuthEnabled: true,
      cinesyncUsername: 'admin',
      cinesyncPassword: 'admin',
      mediahubAutoStart: true,
      rtmAutoStart: false,
      fileOperationsAutoMode: true,
      dbThrottleRate: 100,
      dbMaxRetries: 10,
      dbRetryDelay: 1.0,
      dbBatchSize: 1000,
      dbMaxWorkers: 20,
      // Backend config fields
      origin_directory: '/opt/surge/CineSync/Origin',
      destination_directory: '/opt/surge/CineSync/Destination',
      port: 8080,
      host: '0.0.0.0',
      username: 'admin',
      password: 'surge',
      enable_ssl: false,
      ssl_cert: '',
      ssl_key: '',
      webhook_url: '',
      extra_env: {},
      extra_args: '',
    },
    // Media Automation - Placeholdarr settings
    placeholdarrSettings: {
      plexUrl: '',
      plexToken: '',
      radarrUrl: '',
      radarrApiKey: '',
      sonarrUrl: '',
      sonarrApiKey: '',
      movieLibraryFolder: '',
      tvLibraryFolder: '',
      dummyFilePath: '',
      placeholderStrategy: 'hardlink',
      tvPlayMode: 'episode',
      titleUpdates: 'OFF',
      includeSpecials: false,
      episodesLookahead: 0,
      maxMonitorTime: 0,
      checkInterval: 0,
      availableCleanupDelay: 0,
      calendarLookaheadDays: 0,
      calendarSyncIntervalHours: 0,
      enableComingSoonPlaceholders: false,
      preferredMovieDateType: 'inCinemas',
      enableComingSoonCountdown: false,
      calendarPlaceholderMode: 'episode',
      comingSoonDummyFilePath: '',
      apiKey: 'surgestack',
      authMethod: 'Basic',
      logLevel: 'Info',
      branch: 'master',
      launchBrowser: 'false',
    },
    // Download Clients & Tools
    nzbgetUrl: '',
    nzbgetApiKey: '',
    nzbgetPort: '',
    nzbgetUsername: '',
    nzbgetPassword: '',
    nzbgetSsl: 'false',
    nzbgetDestinationDirectory: '',
    rdtClientUrl: '', rdtClientApiKey: '',
    // Decypharr (common fields)
    decypharrUrl: '',
    decypharrApiKey: '',
    decypharrDownloadFolder: '',
    decypharrCategories: '',
    decypharrUseAuth: false,
    decypharrPort: 8282,
    decypharrLogLevel: 'info',
    // Decypharr (advanced fields)
    decypharrMinFileSize: '',
    decypharrMaxFileSize: '',
    decypharrAllowedFileTypes: '',
    decypharrRateLimit: '',
    decypharrDownloadUncached: false,
    decypharrCheckCached: false,
    decypharrUseWebdav: false,
    decypharrProxy: '',
    decypharrTorrentsRefreshInterval: '',
    decypharrDownloadLinksRefreshInterval: '',
    decypharrWorkers: '',
    decypharrServeFromRclone: false,
    decypharrAddSamples: false,
    decypharrFolderNaming: '',
    decypharrAutoExpireLinksAfter: '',
    decypharrRcUrl: '',
    decypharrRcUser: '',
    decypharrRcPass: '',
    decypharrRcRefreshDirs: '',
    decypharrDirectories: '',
    decypharrRefreshInterval: '',
    decypharrMaxDownloads: '',
    decypharrSkipPreCache: false,
    // Content Enhancement
    kometaUrl: '', kometaApiKey: '',
    posterizarrUrl: '', posterizarrApiKey: '',
    // Monitoring & Interface
    overseerrUrl: '', overseerrApiKey: '',
    tautulliUrl: '', tautulliApiKey: '',
    // Shared Configuration
    destinationDir: '',
    discordWebhook: '',
    traktApiKey: '',
    // External API Keys
    tmdbApiKey: '',
    fanartApiKey: '',
    tvdbApiKey: '',
    rdApiToken: '',
    adApiToken: '',
    premiumizeApiToken: '',
    timezone: '',
    userId: '',
    groupId: '',
    umask: '',
    tz: '',
    // Zurg Configuration
    zurgToken: '',
    // Media Server Configuration
    plexSettings: {
      HOSTNAME: 'PlexServer',
      TZ: 'UTC',
      PLEX_CLAIM: '',
      ADVERTISE_IP: '',
      PLEX_UID: 1000,
      PLEX_GID: 1000,
      CHANGE_CONFIG_DIR_OWNERSHIP: true,
      ALLOWED_NETWORKS: '',
      extra_env: {},
      extra_args: '',
    },
    jellyfinSettings: {
      TZ: 'UTC',
      JELLYFIN_PublishedServerUrl: '',
      JELLYFIN_LOG_DIR: '',
      JELLYFIN_DATA_DIR: '',
      JELLYFIN_CONFIG_DIR: '',
      JELLYFIN_CACHE_DIR: '',
      JELLYFIN_FFMPEG_PATH: '',
      extra_env: {},
      extra_args: '',
    },
    embySettings: {
      TZ: 'UTC',
      EMBY_DATA_DIR: '',
      EMBY_CONFIG_DIR: '',
      EMBY_CACHE_DIR: '',
      extra_env: {},
      extra_args: '',
    }
  });

  // Autodetect URLs and API keys (example: fetch from backend or localStorage)
  useEffect(() => {
    async function fetchDefaults() {
      // Try to fetch autodetected config from backend (implement endpoint if needed)
      try {
        const resp = await fetch('/api/autodetect');
        if (resp.ok) {
          const data = await resp.json();
          setConfig((prev) => ({ ...prev, ...data }));
        }
      } catch (e) {
        // fallback: try localStorage
        const local = localStorage.getItem('surge-setup');
        if (local) {
          try {
            setConfig((prev) => ({ ...prev, ...JSON.parse(local) }));
          } catch (err) {
            console.error('Failed to parse localStorage surge-setup:', local, err);
            alert('Error: Failed to parse saved setup from localStorage. Value: ' + local + '\nError: ' + err.message);
          }
        }
      }
    }
    fetchDefaults();
  }, []);
  const [testResult, setTestResult] = React.useState('');
  const [deployResult, setDeployResult] = React.useState('');

  const handleNext = () => setActiveStep((prev) => prev + 1);
  // Custom next handler for media server step
  const handleBack = () => setActiveStep((prev) => prev - 1);

  const handleChange = (e) => {
    setConfig({ ...config, [e.target.name]: e.target.value });
  };

  const handleTest = async (service) => {
    setTestResult('Testing...');
    let url = '', api_key = '';
    if (service === 'prowlarr') {
      url = config.prowlarrUrl; api_key = config.prowlarrApiKey;
    } else if (service === 'radarr') {
      url = config.radarrUrl; api_key = config.radarrApiKey;
    } else if (service === 'sonarr') {
      url = config.sonarrUrl; api_key = config.sonarrApiKey;
    }
    try {
      const resp = await fetch('/api/test_connection', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ url, api_key })
      });
      const text = await resp.text();
      let data;
      try {
        data = JSON.parse(text);
      } catch (e) {
        console.error('Failed to parse JSON from /api/test_connection:', text, e);
        setTestResult('Error: Invalid JSON response from backend. Value: ' + text + '\nError: ' + e.message);
        return;
      }
      setTestResult(data.status === 'success' ? 'Connection successful!' : 'Failed: ' + (data.error || data.output));
    } catch (e) {
      setTestResult('Error: ' + e.message);
    }
  };

  const handleSave = async () => {
    localStorage.setItem('surge-setup', JSON.stringify(config));
    await fetch('/api/save_config', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(config)
    });
  };

  const handleDeploy = async () => {
    setDeployResult('Deploying...');
    try {
      const resp = await fetch('/api/deploy', { method: 'POST' });
      const text = await resp.text();
      let data;
      try {
        data = JSON.parse(text);
      } catch (e) {
        console.error('Failed to parse JSON from /api/deploy:', text, e);
        setDeployResult('Error: Invalid JSON response from backend. Value: ' + text + '\nError: ' + e.message);
        return;
      }
      setDeployResult(data.status === 'deployed' ? 'Deployment successful!' : 'Failed: ' + (data.error || data.output));
    } catch (e) {
      setDeployResult('Error: ' + e.message);
    }
  }

  return (
    <>
      {jsonParseError && (
        <div style={{ background: '#ffdddd', color: '#900', padding: 16, margin: 16, border: '2px solid #900', borderRadius: 8, fontFamily: 'monospace', whiteSpace: 'pre-wrap', zIndex: 9999 }}>
          <b>JSON Parse Error:</b><br />
          {jsonParseError}
        </div>
      )}
      <div style={{
        minHeight: '100vh',
        minWidth: '100vw',
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        backgroundImage: `url(${bgImage})`,
        backgroundSize: 'cover',
        backgroundPosition: 'center',
        backgroundAttachment: 'fixed',
        zIndex: -1
      }} />
      <div style={{
        minHeight: '100vh',
        width: '100vw',
        position: 'relative',
        display: 'block',
        padding: 0,
        margin: 0,
        zIndex: 1
      }}>
        <Container style={{ width: '100%', background: 'rgba(17,17,17,0.92)', borderRadius: 12, boxShadow: '0 0 24px #000', padding: 0 }}>
        <Box>
        <SurgeLogo />
        <Typography variant="h4" align="center" gutterBottom style={{ color: '#fff' }}>
          Surge Setup
        </Typography>
        <Stepper activeStep={activeStep} alternativeLabel>
          {steps.map((label, idx) => (
            <Step key={label}>
              <StepLabel
                sx={{
                  '& .MuiStepLabel-label': { color: '#fff !important' },
                  '& .MuiStepIcon-root': { color: '#07938f', cursor: 'pointer' }
                }}
                onClick={() => setActiveStep(idx)}
                style={{ cursor: 'pointer' }}
              >
                {label}
              </StepLabel>
            </Step>
          ))}
        </Stepper>
        <Box sx={{ my: 4 }}>
          {activeStep === 0 && (
            <Typography align="center" style={{ color: '#fff' }}>Welcome to Surge! Surge aims to take the hassle out of media server management by allowing you to easily deploy a media server and all the backend software you may need.</Typography>
          )}
          {activeStep === 1 && (
            <Box>
              <Typography variant="h6" style={{ color: '#fff', marginBottom: 16 }}>Core Media Server</Typography>
              <Box display="flex" gap={3} mb={3} justifyContent="center">
                {coreServers.map((srv) => (
                  <Tooltip key={srv.key} title={srv.desc} placement="top">
                    <Box
                      onClick={() => setConfig((prev) => ({ ...prev, mediaServer: prev.mediaServer === srv.key ? '' : srv.key }))}
                      sx={{
                        cursor: 'pointer',
                        opacity: config.mediaServer === srv.key ? 1 : 0.4,
                        filter: config.mediaServer === srv.key ? 'none' : 'grayscale(100%)',
                        border: config.mediaServer === srv.key ? '2px solid #07938f' : '2px solid #444',
                        borderRadius: 2,
                        p: 1,
                        background: '#181818',
                        transition: 'all 0.2s',
                        position: 'relative',
                        boxShadow: config.mediaServer === srv.key ? '0 0 8px #07938f' : 'none',
                        '&:hover': { boxShadow: '0 0 16px #07938f' }
                      }}
                    >
                      <img src={srv.logo} alt={srv.name} style={{ maxWidth: 192, maxHeight: 192, width: 'auto', height: 'auto', display: 'block', margin: '0 auto' }} />
                      {config.mediaServer !== srv.key && (
                        <Box sx={{
                          position: 'absolute',
                          top: 0,
                          left: 0,
                          width: '100%',
                          height: '100%',
                          bgcolor: 'rgba(40,40,40,0.6)',
                          borderRadius: 2
                        }} />
                      )}
                    </Box>
                  </Tooltip>
                ))}
              </Box>
              
              {/* Media Server Configuration */}
              {config.mediaServer && (
                <Box mt={4} p={2} sx={{ background: '#1a1a1a', borderRadius: 2, border: '1px solid #333' }}>
                  <Typography variant="h6" style={{ color: '#fff', marginBottom: 16 }}>
                    {coreServers.find(s => s.key === config.mediaServer)?.name} Configuration
                  </Typography>
                  
                  {config.mediaServer === 'plex' && (
                    <Box>
                      <Box display="flex" gap={2} mb={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', marginBottom: 8 }}>Server Name</Typography>
                          <input
                            type="text"
                            value={config.plexSettings.HOSTNAME}
                            onChange={(e) => setConfig(prev => ({
                              ...prev,
                              plexSettings: { ...prev.plexSettings, HOSTNAME: e.target.value }
                            }))}
                            placeholder="PlexServer"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          />
                          <Typography style={{ color: '#aaa', fontSize: 12, marginTop: 4 }}>
                            The friendly name for your Plex server
                          </Typography>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', marginBottom: 8 }}>Plex Claim Token (Optional)</Typography>
                          <input
                            type="text"
                            value={config.plexSettings.PLEX_CLAIM}
                            onChange={(e) => setConfig(prev => ({
                              ...prev,
                              plexSettings: { ...prev.plexSettings, PLEX_CLAIM: e.target.value }
                            }))}
                            placeholder="claim-xxxxxxxxx"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          />
                          <Typography style={{ color: '#aaa', fontSize: 12, marginTop: 4 }}>
                            Get from <a href="https://plex.tv/claim" target="_blank" rel="noopener noreferrer" style={{ color: '#07938f' }}>plex.tv/claim</a>
                          </Typography>
                        </Box>
                      </Box>
                      
                      <Box mt={3} p={2} sx={{ background: '#252525', borderRadius: 1, border: '1px solid #444' }}>
                        <Typography style={{ color: '#fff', fontWeight: 'bold', marginBottom: 8 }}>
                          🎬 Automatic Library Creation
                        </Typography>
                        <Typography style={{ color: '#aaa', fontSize: 14 }}>
                          Surge will automatically create Plex libraries based on your CineSync folder structure:
                        </Typography>
                        <Box mt={1} ml={2}>
                          <Typography style={{ color: '#fff', fontSize: 13 }}>• Movies</Typography>
                          <Typography style={{ color: '#fff', fontSize: 13 }}>• TV Shows</Typography>
                          <Typography style={{ color: '#fff', fontSize: 13 }}>• Anime Movies</Typography>
                          <Typography style={{ color: '#fff', fontSize: 13 }}>• Anime Series</Typography>
                        </Box>
                        <Typography style={{ color: '#aaa', fontSize: 12, marginTop: 8 }}>
                          Libraries will be created automatically after deployment with proper metadata agents.
                        </Typography>
                      </Box>
                    </Box>
                  )}
                  
                  {config.mediaServer === 'jellyfin' && (
                    <Box>
                      <Box display="flex" gap={2} mb={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', marginBottom: 8 }}>Published Server URL</Typography>
                          <input
                            type="text"
                            value={config.jellyfinSettings.JELLYFIN_PublishedServerUrl}
                            onChange={(e) => setConfig(prev => ({
                              ...prev,
                              jellyfinSettings: { ...prev.jellyfinSettings, JELLYFIN_PublishedServerUrl: e.target.value }
                            }))}
                            placeholder="https://jellyfin.yourdomain.com"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          />
                          <Typography style={{ color: '#aaa', fontSize: 12, marginTop: 4 }}>
                            The external URL for your Jellyfin server
                          </Typography>
                        </Box>
                      </Box>
                    </Box>
                  )}
                  
                  {config.mediaServer === 'emby' && (
                    <Box>
                      <Typography style={{ color: '#fff', marginBottom: 8 }}>Emby Configuration</Typography>
                      <Typography style={{ color: '#aaa', fontSize: 14 }}>
                        Basic Emby setup with default configuration. Advanced settings can be configured after deployment.
                      </Typography>
                    </Box>
                  )}
                </Box>
              )}
            </Box>
          )}
          {activeStep === 2 && (
            <Box>
              <Typography variant="h6" style={{ color: '#fff', marginBottom: 16 }}>Storage Config</Typography>
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
                    // Use the File System Access API if available
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
            </Box>
          )}
          {activeStep === 3 && (
            <Box>
              <Typography variant="h6" style={{ color: '#fff', marginBottom: 16 }}>Media Automation & Management</Typography>
              <Box display="flex" gap={3} mb={3} justifyContent="center">
                {Object.keys(serviceLogos).map((service) => (
                  <Tooltip key={service} title={serviceDescriptions[service]} placement="top">
                    <Box
                      onClick={() => setMediaAutomation((prev) => ({ ...prev, [service]: !prev[service] }))}
                      sx={{
                        cursor: 'pointer',
                        opacity: mediaAutomation[service] ? 1 : 0.4,
                        filter: mediaAutomation[service] ? 'none' : 'grayscale(100%)',
                        border: mediaAutomation[service] ? '2px solid #07938f' : '2px solid #444',
                        borderRadius: 2,
                        p: 1,
                        background: '#181818',
                        transition: 'all 0.2s',
                        position: 'relative',
                        boxShadow: mediaAutomation[service] ? '0 0 8px #07938f' : 'none',
                        '&:hover': { boxShadow: '0 0 16px #07938f' }
                      }}
                    >
                      <img src={serviceLogos[service]} alt={service} style={{ width: 64, height: 64, display: 'block', margin: '0 auto' }} />
                      <Typography align="center" style={{ color: '#fff', fontSize: 14, marginTop: 4 }}>{service.charAt(0).toUpperCase() + service.slice(1)}</Typography>
                      {!mediaAutomation[service] && (
                        <Box sx={{
                          position: 'absolute',
                          top: 0,
                          left: 0,
                          width: '100%',
                          height: '100%',
                          bgcolor: 'rgba(40,40,40,0.6)',
                          borderRadius: 2
                        }} />
                      )}
                    </Box>
                  </Tooltip>
                ))}
              </Box>
              {/* Sub-sections for enabled services */}
              {Object.keys(serviceLogos).filter((service) => mediaAutomation[service]).map((service) => (
                <Box key={service} sx={{ background: '#232323', borderRadius: 2, p: 2, mb: 2, mt: 2, border: '2px solid #07938f' }}>
                  <Typography variant="subtitle1" style={{ color: '#fff', fontWeight: 600, marginBottom: 8 }}>{service.charAt(0).toUpperCase() + service.slice(1)}</Typography>
                  {service === 'radarr' || service === 'sonarr' || service === 'prowlarr' || service === 'bazarr' ? (
                    <Box display="flex" flexDirection="column" gap={3}>
                      {/* CineSync Advanced Config Toggle */}
                      <Box mt={2}>
                        <Divider sx={{ my: 2, borderColor: '#07938f' }} />
                        <Button
                          variant="outlined"
                          style={{ color: '#fff', borderColor: '#07938f', marginTop: 8 }}
                          onClick={() => setShowCineSyncAdvanced((prev) => !prev)}
                        >
                          {showCineSyncAdvanced ? 'Hide' : 'Show'} Advanced Config
                        </Button>
                        {showCineSyncAdvanced && (
                          <Box sx={{ background: '#181818', borderRadius: 2, p: 2, border: '1px solid #07938f', mt: 2 }}>
                            <Typography variant="subtitle2" style={{ color: '#79eaff', marginBottom: 8 }}>
                              CineSync Advanced Config
                            </Typography>
                            <Box display="flex" gap={2} flexWrap="wrap">
                              {/* Advanced CineSync fields */}
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Custom Show Folder</Typography><input name="cinesync_customShowFolder" value={config.cinesyncSettings.customShowFolder || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, customShowFolder: e.target.value } }))} placeholder="/shows" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Custom 4K Show Folder</Typography><input name="cinesync_custom4kShowFolder" value={config.cinesyncSettings.custom4kShowFolder || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, custom4kShowFolder: e.target.value } }))} placeholder="/shows-4k" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Custom Anime Show Folder</Typography><input name="cinesync_customAnimeShowFolder" value={config.cinesyncSettings.customAnimeShowFolder || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, customAnimeShowFolder: e.target.value } }))} placeholder="/shows-anime" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Custom Movie Folder</Typography><input name="cinesync_customMovieFolder" value={config.cinesyncSettings.customMovieFolder || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, customMovieFolder: e.target.value } }))} placeholder="/movies" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Custom 4K Movie Folder</Typography><input name="cinesync_custom4kMovieFolder" value={config.cinesyncSettings.custom4kMovieFolder || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, custom4kMovieFolder: e.target.value } }))} placeholder="/movies-4k" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Custom Anime Movie Folder</Typography><input name="cinesync_customAnimeMovieFolder" value={config.cinesyncSettings.customAnimeMovieFolder || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, customAnimeMovieFolder: e.target.value } }))} placeholder="/movies-anime" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Custom Kids Movie Folder</Typography><input name="cinesync_customKidsMovieFolder" value={config.cinesyncSettings.customKidsMovieFolder || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, customKidsMovieFolder: e.target.value } }))} placeholder="/movies-kids" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Custom Kids Show Folder</Typography><input name="cinesync_customKidsShowFolder" value={config.cinesyncSettings.customKidsShowFolder || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, customKidsShowFolder: e.target.value } }))} placeholder="/shows-kids" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Show Resolution Structure</Typography><select name="cinesync_showResolutionStructure" value={config.cinesyncSettings.showResolutionStructure ? 'true' : 'false'} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, showResolutionStructure: e.target.value === 'true' } }))} style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}><option value="false">False</option><option value="true">True</option></select></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Movie Resolution Structure</Typography><select name="cinesync_movieResolutionStructure" value={config.cinesyncSettings.movieResolutionStructure ? 'true' : 'false'} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, movieResolutionStructure: e.target.value === 'true' } }))} style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}><option value="false">False</option><option value="true">True</option></select></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>CineSync IP</Typography><input name="cinesync_cinesyncIp" value={config.cinesyncSettings.cinesyncIp || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, cinesyncIp: e.target.value } }))} placeholder="0.0.0.0" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Auth Enabled</Typography><select name="cinesync_cinesyncAuthEnabled" value={config.cinesyncSettings.cinesyncAuthEnabled ? 'true' : 'false'} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, cinesyncAuthEnabled: e.target.value === 'true' } }))} style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}><option value="false">False</option><option value="true">True</option></select></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Username</Typography><input name="cinesync_cinesyncUsername" value={config.cinesyncSettings.cinesyncUsername || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, cinesyncUsername: e.target.value } }))} placeholder="admin" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Password</Typography><input name="cinesync_cinesyncPassword" value={config.cinesyncSettings.cinesyncPassword || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, cinesyncPassword: e.target.value } }))} placeholder="admin" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Origin Directory</Typography><input name="cinesync_origin_directory" value={config.cinesyncSettings.origin_directory || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, origin_directory: e.target.value } }))} placeholder="/opt/surge/CineSync/Origin" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Destination Directory</Typography><input name="cinesync_destination_directory" value={config.cinesyncSettings.destination_directory || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, destination_directory: e.target.value } }))} placeholder="/opt/surge/CineSync/Destination" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                            </Box>
                          </Box>
                        )}
                      </Box>
                      {/* Bazarr Advanced Config Toggle */}
                      {service === 'bazarr' && (
                        <Box mt={2}>
                          <Divider sx={{ my: 2, borderColor: '#07938f' }} />
                          <Button
                            variant="outlined"
                            style={{ color: '#fff', borderColor: '#07938f', marginTop: 8 }}
                            onClick={() => setShowBazarrAdvanced((prev) => !prev)}
                          >
                            {showBazarrAdvanced ? 'Hide' : 'Show'} Advanced Config
                          </Button>
                          {showBazarrAdvanced && (
                            <Box sx={{ background: '#181818', borderRadius: 2, p: 2, border: '1px solid #07938f', mt: 2 }}>
                              <Typography variant="subtitle2" style={{ color: '#79eaff', marginBottom: 8 }}>
                                Bazarr Advanced Config
                              </Typography>
                              <Box display="flex" gap={2} flexWrap="wrap">
                                {/* Advanced Bazarr fields */}
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>App Data</Typography><input name="bazarr_appData" value={config.bazarrSettings.appData || ''} onChange={e => setConfig(prev => ({ ...prev, bazarrSettings: { ...prev.bazarrSettings, appData: e.target.value } }))} placeholder="/appdata" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Config Path</Typography><input name="bazarr_configPath" value={config.bazarrSettings.configPath || ''} onChange={e => setConfig(prev => ({ ...prev, bazarrSettings: { ...prev.bazarrSettings, configPath: e.target.value } }))} placeholder="/config" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Analytics Enabled</Typography><select name="bazarr_analyticsEnabled" value={config.bazarrSettings.analyticsEnabled || 'false'} onChange={e => setConfig(prev => ({ ...prev, bazarrSettings: { ...prev.bazarrSettings, analyticsEnabled: e.target.value } }))} style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}><option value="false">False</option><option value="true">True</option></select></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Update Automatically</Typography><select name="bazarr_updateAutomatically" value={config.bazarrSettings.updateAutomatically || 'false'} onChange={e => setConfig(prev => ({ ...prev, bazarrSettings: { ...prev.bazarrSettings, updateAutomatically: e.target.value } }))} style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}><option value="false">False</option><option value="true">True</option></select></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Update Mechanism</Typography><input name="bazarr_updateMechanism" value={config.bazarrSettings.updateMechanism || ''} onChange={e => setConfig(prev => ({ ...prev, bazarrSettings: { ...prev.bazarrSettings, updateMechanism: e.target.value } }))} placeholder="Docker/Script/None" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Log Rotate (days)</Typography><input name="bazarr_logRotate" value={config.bazarrSettings.logRotate || ''} onChange={e => setConfig(prev => ({ ...prev, bazarrSettings: { ...prev.bazarrSettings, logRotate: e.target.value } }))} placeholder="7" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Backup Retention (days)</Typography><input name="bazarr_backupRetention" value={config.bazarrSettings.backupRetention || ''} onChange={e => setConfig(prev => ({ ...prev, bazarrSettings: { ...prev.bazarrSettings, backupRetention: e.target.value } }))} placeholder="30" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Proxy Enabled</Typography><select name="bazarr_proxyEnabled" value={config.bazarrSettings.proxyEnabled || 'false'} onChange={e => setConfig(prev => ({ ...prev, bazarrSettings: { ...prev.bazarrSettings, proxyEnabled: e.target.value } }))} style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}><option value="false">False</option><option value="true">True</option></select></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Proxy Type</Typography><input name="bazarr_proxyType" value={config.bazarrSettings.proxyType || ''} onChange={e => setConfig(prev => ({ ...prev, bazarrSettings: { ...prev.bazarrSettings, proxyType: e.target.value } }))} placeholder="HTTP/SOCKS5" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Proxy Hostname</Typography><input name="bazarr_proxyHostname" value={config.bazarrSettings.proxyHostname || ''} onChange={e => setConfig(prev => ({ ...prev, bazarrSettings: { ...prev.bazarrSettings, proxyHostname: e.target.value } }))} placeholder="proxy.example.com" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Proxy Port</Typography><input name="bazarr_proxyPort" value={config.bazarrSettings.proxyPort || ''} onChange={e => setConfig(prev => ({ ...prev, bazarrSettings: { ...prev.bazarrSettings, proxyPort: e.target.value } }))} placeholder="8080" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Proxy Username</Typography><input name="bazarr_proxyUsername" value={config.bazarrSettings.proxyUsername || ''} onChange={e => setConfig(prev => ({ ...prev, bazarrSettings: { ...prev.bazarrSettings, proxyUsername: e.target.value } }))} placeholder="username" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Proxy Password</Typography><input name="bazarr_proxyPassword" value={config.bazarrSettings.proxyPassword || ''} onChange={e => setConfig(prev => ({ ...prev, bazarrSettings: { ...prev.bazarrSettings, proxyPassword: e.target.value } }))} placeholder="password" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              </Box>
                            </Box>
                          )}
                        </Box>
                      )}
                        {/* Main network and API settings for each service should only appear in their respective section. */}
                      {/* Thorough Advanced Config for Prowlarr */}
                      {service === 'prowlarr' && (
                        <>
                          {/* Main network and API settings for Prowlarr */}
                          {/* Main network and API settings for Prowlarr should only appear once at the top of the section. */}
                          {/* Advanced Config button and section at the bottom */}
                          <Box mt={2}>
                          <Divider sx={{ my: 2, borderColor: '#07938f' }} />
                          <Button
                            variant="outlined"
                            style={{ color: '#fff', borderColor: '#07938f', marginTop: 8 }}
                            onClick={() => setShowProwlarrAdvanced((prev) => !prev)}
                          >
                            {showProwlarrAdvanced ? 'Hide' : 'Show'} Advanced Config
                          </Button>
                          {showProwlarrAdvanced && (
                            <Box sx={{ background: '#181818', borderRadius: 2, p: 2, border: '1px solid #07938f', mt: 2 }}>
                              <Typography variant="subtitle2" style={{ color: '#79eaff', marginBottom: 8 }}>
                                Prowlarr Advanced Config
                              </Typography>
                              <Box display="flex" gap={2} flexWrap="wrap">
                                {/* All backend fields for Prowlarr Advanced */}
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>PUID</Typography><input name="prowlarr_PUID" value={config.prowlarrSettings.PUID || ''} onChange={e => setConfig(prev => ({ ...prev, prowlarrSettings: { ...prev.prowlarrSettings, PUID: e.target.value } }))} placeholder="1000" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>PGID</Typography><input name="prowlarr_PGID" value={config.prowlarrSettings.PGID || ''} onChange={e => setConfig(prev => ({ ...prev, prowlarrSettings: { ...prev.prowlarrSettings, PGID: e.target.value } }))} placeholder="1000" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>TZ</Typography><input name="prowlarr_TZ" value={config.prowlarrSettings.TZ || ''} onChange={e => setConfig(prev => ({ ...prev, prowlarrSettings: { ...prev.prowlarrSettings, TZ: e.target.value } }))} placeholder="UTC" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>UMASK</Typography><input name="prowlarr_UMASK" value={config.prowlarrSettings.UMASK || ''} onChange={e => setConfig(prev => ({ ...prev, prowlarrSettings: { ...prev.prowlarrSettings, UMASK: e.target.value } }))} placeholder="002" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Host</Typography><input name="prowlarr_host" value={config.prowlarrSettings.host || ''} onChange={e => setConfig(prev => ({ ...prev, prowlarrSettings: { ...prev.prowlarrSettings, host: e.target.value } }))} placeholder="0.0.0.0" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>SSL Cert</Typography><input name="prowlarr_ssl_cert" value={config.prowlarrSettings.ssl_cert || ''} onChange={e => setConfig(prev => ({ ...prev, prowlarrSettings: { ...prev.prowlarrSettings, ssl_cert: e.target.value } }))} placeholder="" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>SSL Key</Typography><input name="prowlarr_ssl_key" value={config.prowlarrSettings.ssl_key || ''} onChange={e => setConfig(prev => ({ ...prev, prowlarrSettings: { ...prev.prowlarrSettings, ssl_key: e.target.value } }))} placeholder="" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Extra Env (JSON)</Typography><input name="prowlarr_extra_env" value={JSON.stringify(config.prowlarrSettings.extra_env || {})} onChange={e => {let val = {};try { val = JSON.parse(e.target.value); } catch {}setConfig(prev => ({ ...prev, prowlarrSettings: { ...prev.prowlarrSettings, extra_env: val } }));}} placeholder='{"MYVAR": "value"}' style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Extra Args</Typography><input name="prowlarr_extra_args" value={config.prowlarrSettings.extra_args || ''} onChange={e => setConfig(prev => ({ ...prev, prowlarrSettings: { ...prev.prowlarrSettings, extra_args: e.target.value } }))} placeholder="--some-flag" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              </Box>
                            </Box>
                          )}
                          </Box>
                        </>
                      )}
                      {/* Thorough Advanced Config for Sonarr */}
                      {service === 'sonarr' && (
                        <Box mt={2}>
                          {/* Advanced Config button and section moved to bottom */}
                          <Divider sx={{ my: 2, borderColor: '#07938f' }} />
                          <Button
                            variant="outlined"
                            style={{ color: '#fff', borderColor: '#07938f', marginTop: 8 }}
                            onClick={() => setShowSonarrAdvanced((prev) => !prev)}
                          >
                            {showSonarrAdvanced ? 'Hide' : 'Show'} Advanced Config
                          </Button>
                          {showSonarrAdvanced && (
                            <Box sx={{ background: '#181818', borderRadius: 2, p: 2, border: '1px solid #07938f', mt: 2 }}>
                              <Typography variant="subtitle2" style={{ color: '#79eaff', marginBottom: 8 }}>
                                Sonarr Advanced Config
                              </Typography>
                              <Box display="flex" gap={2} flexWrap="wrap">
                                {/* All backend fields for Sonarr */}
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>PUID</Typography><input name="sonarr_PUID" value={config.sonarrSettings.PUID || ''} onChange={e => setConfig(prev => ({ ...prev, sonarrSettings: { ...prev.sonarrSettings, PUID: e.target.value } }))} placeholder="1000" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>PGID</Typography><input name="sonarr_PGID" value={config.sonarrSettings.PGID || ''} onChange={e => setConfig(prev => ({ ...prev, sonarrSettings: { ...prev.sonarrSettings, PGID: e.target.value } }))} placeholder="1000" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>TZ</Typography><input name="sonarr_TZ" value={config.sonarrSettings.TZ || ''} onChange={e => setConfig(prev => ({ ...prev, sonarrSettings: { ...prev.sonarrSettings, TZ: e.target.value } }))} placeholder="UTC" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>UMASK</Typography><input name="sonarr_UMASK" value={config.sonarrSettings.UMASK || ''} onChange={e => setConfig(prev => ({ ...prev, sonarrSettings: { ...prev.sonarrSettings, UMASK: e.target.value } }))} placeholder="002" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Config Path</Typography><input name="sonarr_config_path" value={config.sonarrSettings.config_path || ''} onChange={e => setConfig(prev => ({ ...prev, sonarrSettings: { ...prev.sonarrSettings, config_path: e.target.value } }))} placeholder="/config" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>TV Path</Typography><input name="sonarr_tv_path" value={config.sonarrSettings.tv_path || ''} onChange={e => setConfig(prev => ({ ...prev, sonarrSettings: { ...prev.sonarrSettings, tv_path: e.target.value } }))} placeholder="/tv" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Downloads Path</Typography><input name="sonarr_downloads_path" value={config.sonarrSettings.downloads_path || ''} onChange={e => setConfig(prev => ({ ...prev, sonarrSettings: { ...prev.sonarrSettings, downloads_path: e.target.value } }))} placeholder="/downloads" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Read Only</Typography><select name="sonarr_read_only" value={config.sonarrSettings.read_only ? 'true' : 'false'} onChange={e => setConfig(prev => ({ ...prev, sonarrSettings: { ...prev.sonarrSettings, read_only: e.target.value === 'true' } }))} style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}><option value="false">False</option><option value="true">True</option></select></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>User Override</Typography><input name="sonarr_user_override" value={config.sonarrSettings.user_override || ''} onChange={e => setConfig(prev => ({ ...prev, sonarrSettings: { ...prev.sonarrSettings, user_override: e.target.value } }))} placeholder="1000:1000" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Docker Secrets (JSON)</Typography><input name="sonarr_docker_secrets" value={JSON.stringify(config.sonarrSettings.docker_secrets || {})} onChange={e => {let val = {};try { val = JSON.parse(e.target.value); } catch {}setConfig(prev => ({ ...prev, sonarrSettings: { ...prev.sonarrSettings, docker_secrets: val } }));}} placeholder='{"FILE__MYVAR": "/run/secrets/mysecretvariable"}' style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Extra Env (JSON)</Typography><input name="sonarr_extra_env" value={JSON.stringify(config.sonarrSettings.extra_env || {})} onChange={e => {let val = {};try { val = JSON.parse(e.target.value); } catch {}setConfig(prev => ({ ...prev, sonarrSettings: { ...prev.sonarrSettings, extra_env: val } }));}} placeholder='{"MYVAR": "value"}' style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Extra Args</Typography><input name="sonarr_extra_args" value={config.sonarrSettings.extra_args || ''} onChange={e => setConfig(prev => ({ ...prev, sonarrSettings: { ...prev.sonarrSettings, extra_args: e.target.value } }))} placeholder="--some-flag" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              </Box>
                            </Box>
                          )}
                        </Box>
                      )}
                      {/* Thorough Advanced Config for Radarr */}
                      {service === 'radarr' && (
                        <Box mt={2}>
                          {/* Advanced Config button and section moved to bottom */}
                          <Divider sx={{ my: 2, borderColor: '#07938f' }} />
                          <Button
                            variant="outlined"
                            style={{ color: '#fff', borderColor: '#07938f', marginTop: 8 }}
                            onClick={() => setShowRadarrAdvanced((prev) => !prev)}
                          >
                            {showRadarrAdvanced ? 'Hide' : 'Show'} Advanced Config
                          </Button>
                          {showRadarrAdvanced && (
                            <Box sx={{ background: '#181818', borderRadius: 2, p: 2, border: '1px solid #07938f', mt: 2 }}>
                              <Typography variant="subtitle2" style={{ color: '#79eaff', marginBottom: 8 }}>
                                Radarr Advanced Config
                              </Typography>
                              <Box display="flex" gap={2} flexWrap="wrap">
                                {/* All backend fields for Radarr */}
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>PUID</Typography><input name="radarr_PUID" value={config.radarrSettings.PUID || ''} onChange={e => setConfig(prev => ({ ...prev, radarrSettings: { ...prev.radarrSettings, PUID: e.target.value } }))} placeholder="1000" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>PGID</Typography><input name="radarr_PGID" value={config.radarrSettings.PGID || ''} onChange={e => setConfig(prev => ({ ...prev, radarrSettings: { ...prev.radarrSettings, PGID: e.target.value } }))} placeholder="1000" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>TZ</Typography><input name="radarr_TZ" value={config.radarrSettings.TZ || ''} onChange={e => setConfig(prev => ({ ...prev, radarrSettings: { ...prev.radarrSettings, TZ: e.target.value } }))} placeholder="UTC" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>UMASK</Typography><input name="radarr_UMASK" value={config.radarrSettings.UMASK || ''} onChange={e => setConfig(prev => ({ ...prev, radarrSettings: { ...prev.radarrSettings, UMASK: e.target.value } }))} placeholder="002" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Extra Env (JSON)</Typography><input name="radarr_extra_env" value={JSON.stringify(config.radarrSettings.extra_env || {})} onChange={e => {let val = {};try { val = JSON.parse(e.target.value); } catch {}setConfig(prev => ({ ...prev, radarrSettings: { ...prev.radarrSettings, extra_env: val } }));}} placeholder='{"MYVAR": "value"}' style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                                <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Extra Args</Typography><input name="radarr_extra_args" value={config.radarrSettings.extra_args || ''} onChange={e => setConfig(prev => ({ ...prev, radarrSettings: { ...prev.radarrSettings, extra_args: e.target.value } }))} placeholder="--some-flag" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              </Box>
                            </Box>
                          )}
                        </Box>
                      )}
                      {/* Info tooltips for each field */}
                      {/** Helper for info tooltips */}
                      {(() => {
                        // Field descriptions for tooltips
                        const fieldInfo = {
                          port: 'The main HTTP port for the web interface.',
                          sslPort: 'The HTTPS port for secure web access.',
                          enableSsl: 'Enable or disable SSL (HTTPS) for the web interface.',
                          apiKey: 'API key for accessing the service programmatically.',
                          urlBase: 'Base URL path if running behind a reverse proxy (e.g. /radarr).',
                          authMethod: 'Authentication method for the web interface.',
                          logLevel: 'Verbosity of logs written by the service.',
                          branch: 'Branch or release channel to use for updates.',
                          launchBrowser: 'Whether to launch a browser window on startup.',
                          analyticsEnabled: 'Allow sending anonymous usage analytics.',
                          updateAutomatically: 'Enable automatic updates for the service.',
                          updateMechanism: 'How updates are applied (Docker, Script, None).',
                          logRotate: 'Number of days to keep log files before rotating.',
                          backupRetention: 'Number of days to keep backups before deleting.',
                          proxyEnabled: 'Enable or disable use of a proxy server.',
                          proxyType: 'Type of proxy server (HTTP or SOCKS5).',
                          proxyHostname: 'Hostname or IP address of the proxy server.',
                          proxyPort: 'Port number of the proxy server.',
                          proxyUsername: 'Username for proxy authentication.',
                          proxyPassword: 'Password for proxy authentication.',
                          appData: 'Path to the application data directory.',
                          configPath: 'Path to the main configuration file.',
                          rootFolderPath: 'Path where Radarr stores downloaded movies.',
                          movieProfileId: 'Default quality profile ID for new movies.',
                          minimumAvailability: 'Minimum availability required before grabbing a movie.',
                          puid: 'Process user ID (for Docker/UNIX).',
                          pgid: 'Process group ID (for Docker/UNIX).',
                          umask: 'Umask for file permissions (for Docker/UNIX).',
                          tz: 'Timezone (for Docker/UNIX).'
                        };
                        // Expose for use in field rendering
                        return null;
                      })()}
                      {/* Main network and API settings */}
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Port
                            <Tooltip title="The main HTTP port for the web interface.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_port`}
                            type="text"
                            inputMode="numeric"
                            pattern="[0-9]*"
                            value={config[`${service}Settings`].port}
                            onChange={e => {
                              const val = e.target.value.replace(/[^0-9]/g, '');
                              setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], port: val } }));
                            }}
                            placeholder={service === 'radarr' ? '7878' : service === 'sonarr' ? '8989' : service === 'prowlarr' ? '9696' : '6767'}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            SSL Port
                            <Tooltip title="The HTTPS port for secure web access.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_sslport`}
                            type="text"
                            inputMode="numeric"
                            pattern="[0-9]*"
                            value={config[`${service}Settings`].sslPort || ''}
                            onChange={e => {
                              const val = e.target.value.replace(/[^0-9]/g, '');
                              setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], sslPort: val } }));
                            }}
                            placeholder="443"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Enable SSL
                            <Tooltip title="Enable or disable SSL (HTTPS) for the web interface.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name={`${service}_enablessl`}
                            value={config[`${service}Settings`].enableSsl || 'false'}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], enableSsl: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="false">False</option>
                            <option value="true">True</option>
                          </select>
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={2}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            API Key
                            <Tooltip title="API key for accessing the service programmatically.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_apikey`}
                            value={config[`${service}Settings`].apiKey}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], apiKey: e.target.value } }))}
                            placeholder="surgestack"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={2}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            URL Base
                            <Tooltip title="Base URL path if running behind a reverse proxy (e.g. /radarr).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_urlbase`}
                            value={config[`${service}Settings`].urlBase || ''}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], urlBase: e.target.value } }))}
                            placeholder="/radarr or /sonarr or /prowlarr"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        {service === 'radarr' && (
                          <>
                            <Box flex={2}>
                              <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                                Root Folder Path
                                <Tooltip title="Path where Radarr stores downloaded movies.">
                                  <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                                  </span>
                                </Tooltip>
                              </Typography>
                              <input
                                name="radarr_rootFolderPath"
                                value={config.radarrSettings.rootFolderPath}
                                onChange={e => setConfig(prev => ({ ...prev, radarrSettings: { ...prev.radarrSettings, rootFolderPath: e.target.value } }))}
                                placeholder="/data/movies"
                                style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                              />
                            </Box>
                            <Box flex={2}>
                              <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                                Quality Profile ID
                                <Tooltip title="Default quality profile ID for new movies.">
                                  <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                                  </span>
                                </Tooltip>
                              </Typography>
                              <input
                                name="radarr_movieProfileId"
                                value={config.radarrSettings.movieProfileId}
                                onChange={e => setConfig(prev => ({ ...prev, radarrSettings: { ...prev.radarrSettings, movieProfileId: e.target.value } }))}
                                placeholder="1 (HD-1080p, etc)"
                                style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                              />
                            </Box>
                            <Box flex={2}>
                              <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                                Minimum Availability
                                <Tooltip title="Minimum availability required before grabbing a movie.">
                                  <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                                  </span>
                                </Tooltip>
                              </Typography>
                              <select
                                name="radarr_minimumAvailability"
                                value={config.radarrSettings.minimumAvailability}
                                onChange={e => setConfig(prev => ({ ...prev, radarrSettings: { ...prev.radarrSettings, minimumAvailability: e.target.value } }))}
                                style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                              >
                                <option value="released">Released</option>
                                <option value="cinemas">In Cinemas</option>
                                <option value="announced">Announced</option>
                                <option value="tba">TBA</option>
                              </select>
                            </Box>
                          </>
                        )}
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Authentication Method
                            <Tooltip title="Authentication method for the web interface.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name={`${service}_auth`}
                            value={config[`${service}Settings`].authMethod}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], authMethod: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="Basic">Basic</option>
                            <option value="Forms">Forms</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Log Level
                            <Tooltip title="Verbosity of logs written by the service.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name={`${service}_loglevel`}
                            value={config[`${service}Settings`].logLevel}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], logLevel: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="Trace">Trace</option>
                            <option value="Debug">Debug</option>
                            <option value="Info">Info</option>
                            <option value="Warn">Warn</option>
                            <option value="Error">Error</option>
                            <option value="Fatal">Fatal</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Branch
                            <Tooltip title="Branch or release channel to use for updates.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_branch`}
                            value={config[`${service}Settings`].branch}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], branch: e.target.value } }))}
                            placeholder="master"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Launch Browser
                            <Tooltip title="Whether to launch a browser window on startup.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name={`${service}_launchbrowser`}
                            value={config[`${service}Settings`].launchBrowser}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], launchBrowser: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="false">False</option>
                            <option value="true">True</option>
                          </select>
                        </Box>
                      </Box>
                      {/* Advanced/optional settings */}
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Analytics Enabled
                            <Tooltip title="Allow sending anonymous usage analytics.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name={`${service}_analytics`}
                            value={config[`${service}Settings`].analyticsEnabled || 'false'}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], analyticsEnabled: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="false">False</option>
                            <option value="true">True</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Update Automatically
                            <Tooltip title="Enable automatic updates for the service.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name={`${service}_updateauto`}
                            value={config[`${service}Settings`].updateAutomatically || 'true'}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], updateAutomatically: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="true">True</option>
                            <option value="false">False</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Update Mechanism
                            <Tooltip title="How updates are applied (Docker, Script, None).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name={`${service}_updatemechanism`}
                            value={config[`${service}Settings`].updateMechanism || 'docker'}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], updateMechanism: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="docker">Docker</option>
                            <option value="script">Script</option>
                            <option value="none">None</option>
                          </select>
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Log Rotate (days)
                            <Tooltip title="Number of days to keep log files before rotating.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_logrotate`}
                            type="text"
                            inputMode="numeric"
                            pattern="[0-9]*"
                            value={config[`${service}Settings`].logRotate || ''}
                            onChange={e => {
                              const val = e.target.value.replace(/[^0-9]/g, '');
                              setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], logRotate: val } }));
                            }}
                            placeholder="7"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Backup Retention (days)
                            <Tooltip title="Number of days to keep backups before deleting.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_backupretention`}
                            type="text"
                            inputMode="numeric"
                            pattern="[0-9]*"
                            value={config[`${service}Settings`].backupRetention || ''}
                            onChange={e => {
                              const val = e.target.value.replace(/[^0-9]/g, '');
                              setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], backupRetention: val } }));
                            }}
                            placeholder="30"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                      </Box>
                      {/* Proxy settings */}
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Proxy Enabled
                            <Tooltip title="Enable or disable use of a proxy server.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name={`${service}_proxyenabled`}
                            value={config[`${service}Settings`].proxyEnabled || 'false'}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], proxyEnabled: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="false">False</option>
                            <option value="true">True</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Proxy Type
                            <Tooltip title="Type of proxy server (HTTP or SOCKS5).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name={`${service}_proxytype`}
                            value={config[`${service}Settings`].proxyType || 'http'}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], proxyType: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="http">HTTP</option>
                            <option value="socks5">SOCKS5</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Proxy Hostname
                            <Tooltip title="Hostname or IP address of the proxy server.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_proxyhostname`}
                            value={config[`${service}Settings`].proxyHostname || ''}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], proxyHostname: e.target.value } }))}
                            placeholder="proxy.example.com"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Proxy Port
                            <Tooltip title="Port number of the proxy server.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_proxyport`}
                            type="text"
                            inputMode="numeric"
                            pattern="[0-9]*"
                            value={config[`${service}Settings`].proxyPort || ''}
                            onChange={e => {
                              const val = e.target.value.replace(/[^0-9]/g, '');
                              setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], proxyPort: val } }));
                            }}
                            placeholder="8080"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Proxy Username
                            <Tooltip title="Username for proxy authentication.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_proxyusername`}
                            value={config[`${service}Settings`].proxyUsername || ''}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], proxyUsername: e.target.value } }))}
                            placeholder="username"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Proxy Password
                            <Tooltip title="Password for proxy authentication.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_proxypassword`}
                            type="password"
                            value={config[`${service}Settings`].proxyPassword || ''}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], proxyPassword: e.target.value } }))}
                            placeholder="password"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                      </Box>
                      {/* Additional paths (advanced) */}
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            App Data Path
                            <Tooltip title="Path to the application data directory.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_appdata`}
                            value={config[`${service}Settings`].appData || ''}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], appData: e.target.value } }))}
                            placeholder="/config/{service}"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Config Path
                            <Tooltip title="Path to the main configuration file.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_configpath`}
                            value={config[`${service}Settings`].configPath || ''}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], configPath: e.target.value } }))}
                            placeholder="/config/{service}/config.xml"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                      </Box>
                    </Box>
                  ) : service === 'cinesync' ? (
                    <Box display="flex" flexDirection="column" gap={2}>
                      {/* CineSync Advanced Config Toggle */}
                      <Box mt={2}>
                        <Divider sx={{ my: 2, borderColor: '#07938f' }} />
                        <Button
                          variant="outlined"
                          style={{ color: '#fff', borderColor: '#07938f', marginTop: 8 }}
                          onClick={() => setShowCineSyncAdvanced((prev) => !prev)}
                        >
                          {showCineSyncAdvanced ? 'Hide' : 'Show'} Advanced Config
                        </Button>
                        {showCineSyncAdvanced && (
                          <Box sx={{ background: '#181818', borderRadius: 2, p: 2, border: '1px solid #07938f', mt: 2 }}>
                            <Typography variant="subtitle2" style={{ color: '#79eaff', marginBottom: 8 }}>
                              CineSync Advanced Config
                            </Typography>
                            <Box display="flex" gap={2} flexWrap="wrap">
                              {/* Advanced CineSync fields from GitHub */}
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Custom Show Folder</Typography><input name="cinesync_customShowFolder" value={config.cinesyncSettings.customShowFolder || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, customShowFolder: e.target.value } }))} placeholder="/shows" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Custom 4K Show Folder</Typography><input name="cinesync_custom4kShowFolder" value={config.cinesyncSettings.custom4kShowFolder || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, custom4kShowFolder: e.target.value } }))} placeholder="/shows-4k" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Custom Anime Show Folder</Typography><input name="cinesync_customAnimeShowFolder" value={config.cinesyncSettings.customAnimeShowFolder || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, customAnimeShowFolder: e.target.value } }))} placeholder="/shows-anime" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Custom Movie Folder</Typography><input name="cinesync_customMovieFolder" value={config.cinesyncSettings.customMovieFolder || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, customMovieFolder: e.target.value } }))} placeholder="/movies" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Custom 4K Movie Folder</Typography><input name="cinesync_custom4kMovieFolder" value={config.cinesyncSettings.custom4kMovieFolder || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, custom4kMovieFolder: e.target.value } }))} placeholder="/movies-4k" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Custom Anime Movie Folder</Typography><input name="cinesync_customAnimeMovieFolder" value={config.cinesyncSettings.customAnimeMovieFolder || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, customAnimeMovieFolder: e.target.value } }))} placeholder="/movies-anime" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Custom Kids Movie Folder</Typography><input name="cinesync_customKidsMovieFolder" value={config.cinesyncSettings.customKidsMovieFolder || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, customKidsMovieFolder: e.target.value } }))} placeholder="/movies-kids" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Custom Kids Show Folder</Typography><input name="cinesync_customKidsShowFolder" value={config.cinesyncSettings.customKidsShowFolder || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, customKidsShowFolder: e.target.value } }))} placeholder="/shows-kids" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Show Resolution Structure</Typography><select name="cinesync_showResolutionStructure" value={config.cinesyncSettings.showResolutionStructure ? 'true' : 'false'} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, showResolutionStructure: e.target.value === 'true' } }))} style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}><option value="false">False</option><option value="true">True</option></select></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Movie Resolution Structure</Typography><select name="cinesync_movieResolutionStructure" value={config.cinesyncSettings.movieResolutionStructure ? 'true' : 'false'} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, movieResolutionStructure: e.target.value === 'true' } }))} style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}><option value="false">False</option><option value="true">True</option></select></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>CineSync IP</Typography><input name="cinesync_cinesyncIp" value={config.cinesyncSettings.cinesyncIp || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, cinesyncIp: e.target.value } }))} placeholder="0.0.0.0" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Auth Enabled</Typography><select name="cinesync_cinesyncAuthEnabled" value={config.cinesyncSettings.cinesyncAuthEnabled ? 'true' : 'false'} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, cinesyncAuthEnabled: e.target.value === 'true' } }))} style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}><option value="false">False</option><option value="true">True</option></select></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Username</Typography><input name="cinesync_cinesyncUsername" value={config.cinesyncSettings.cinesyncUsername || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, cinesyncUsername: e.target.value } }))} placeholder="admin" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Password</Typography><input name="cinesync_cinesyncPassword" value={config.cinesyncSettings.cinesyncPassword || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, cinesyncPassword: e.target.value } }))} placeholder="admin" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Origin Directory</Typography><input name="cinesync_origin_directory" value={config.cinesyncSettings.origin_directory || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, origin_directory: e.target.value } }))} placeholder="/opt/surge/CineSync/Origin" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                              <Box flex={1} minWidth={220}><Typography style={{ color: '#fff' }}>Destination Directory</Typography><input name="cinesync_destination_directory" value={config.cinesyncSettings.destination_directory || ''} onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, destination_directory: e.target.value } }))} placeholder="/opt/surge/CineSync/Destination" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} /></Box>
                            </Box>
                          </Box>
                        )}
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            WebUI Port
                            <Tooltip title="The port for the Cinesync web interface.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="cinesync_webuiPort"
                            type="text"
                            inputMode="numeric"
                            pattern="[0-9]*"
                            value={config.cinesyncSettings.webuiPort}
                            onChange={e => {
                              const val = e.target.value.replace(/[^0-9]/g, '');
                              setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, webuiPort: val } }));
                            }}
                            placeholder="5173"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            API Server Port
                            <Tooltip title="The port for the Cinesync API server.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="cinesync_apiPort"
                            type="text"
                            inputMode="numeric"
                            pattern="[0-9]*"
                            value={config.cinesyncSettings.apiPort}
                            onChange={e => {
                              const val = e.target.value.replace(/[^0-9]/g, '');
                              setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, apiPort: val } }));
                            }}
                            placeholder="8082"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            WebDAV Port
                            <Tooltip title="The port for the Cinesync WebDAV server.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="cinesync_webdavPort"
                            type="text"
                            inputMode="numeric"
                            pattern="[0-9]*"
                            value={config.cinesyncSettings.webdavPort}
                            onChange={e => {
                              const val = e.target.value.replace(/[^0-9]/g, '');
                              setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, webdavPort: val } }));
                            }}
                            placeholder="8082"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            API Key
                            <Tooltip title="API key for accessing the Cinesync API.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="cinesync_apiKey"
                            value={config.cinesyncSettings.apiKey}
                            onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, apiKey: e.target.value } }))}
                            placeholder="surgestack"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Authentication Method
                            <Tooltip title="Authentication method for the Cinesync web interface.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name="cinesync_authMethod"
                            value={config.cinesyncSettings.authMethod}
                            onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, authMethod: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="Basic">Basic</option>
                            <option value="Forms">Forms</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Log Level
                            <Tooltip title="Verbosity of logs written by Cinesync.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name="cinesync_logLevel"
                            value={config.cinesyncSettings.logLevel}
                            onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, logLevel: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="Trace">Trace</option>
                            <option value="Debug">Debug</option>
                            <option value="Info">Info</option>
                            <option value="Warn">Warn</option>
                            <option value="Error">Error</option>
                            <option value="Fatal">Fatal</option>
                          </select>
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Branch
                            <Tooltip title="Branch or release channel to use for Cinesync updates.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="cinesync_branch"
                            value={config.cinesyncSettings.branch}
                            onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, branch: e.target.value } }))}
                            placeholder="master"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Launch Browser
                            <Tooltip title="Whether to launch a browser window on Cinesync startup.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name="cinesync_launchBrowser"
                            value={config.cinesyncSettings.launchBrowser}
                            onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, launchBrowser: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="false">False</option>
                            <option value="true">True</option>
                          </select>
                        </Box>
                      </Box>
                    </Box>
                  ) : service === 'placeholdarr' ? (
                    <Box display="flex" flexDirection="column" gap={2}>
                      {/* First row: Plex, Radarr, Sonarr URLs and API keys */}
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Plex URL</Typography>
                          <input
                            name="placeholdarr_plexUrl"
                            value={config.placeholdarrSettings.plexUrl}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, plexUrl: e.target.value } }))}
                            placeholder="http://plex:32400"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Plex Token</Typography>
                          <input
                            name="placeholdarr_plexToken"
                            value={config.placeholdarrSettings.plexToken}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, plexToken: e.target.value } }))}
                            placeholder=""
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Radarr URL</Typography>
                          <input
                            name="placeholdarr_radarrUrl"
                            value={config.placeholdarrSettings.radarrUrl}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, radarrUrl: e.target.value } }))}
                            placeholder="http://radarr:7878"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Radarr API Key</Typography>
                          <input
                            name="placeholdarr_radarrApiKey"
                            value={config.placeholdarrSettings.radarrApiKey}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, radarrApiKey: e.target.value } }))}
                            placeholder=""
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          />
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Sonarr URL</Typography>
                          <input
                            name="placeholdarr_sonarrUrl"
                            value={config.placeholdarrSettings.sonarrUrl}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, sonarrUrl: e.target.value } }))}
                            placeholder="http://sonarr:8989"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Sonarr API Key</Typography>
                          <input
                            name="placeholdarr_sonarrApiKey"
                            value={config.placeholdarrSettings.sonarrApiKey}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, sonarrApiKey: e.target.value } }))}
                            placeholder=""
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Movie Library Folder</Typography>
                          <input
                            name="placeholdarr_movieLibraryFolder"
                            value={config.placeholdarrSettings.movieLibraryFolder}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, movieLibraryFolder: e.target.value } }))}
                            placeholder="/data/media/movies"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>TV Library Folder</Typography>
                          <input
                            name="placeholdarr_tvLibraryFolder"
                            value={config.placeholdarrSettings.tvLibraryFolder}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, tvLibraryFolder: e.target.value } }))}
                            placeholder="/data/media/tv"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          />
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Dummy File Path</Typography>
                          <input
                            name="placeholdarr_dummyFilePath"
                            value={config.placeholdarrSettings.dummyFilePath}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, dummyFilePath: e.target.value } }))}
                            placeholder="/data/media/placeholder.mkv"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Placeholder Strategy</Typography>
                          <select
                            name="placeholdarr_placeholderStrategy"
                            value={config.placeholdarrSettings.placeholderStrategy}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, placeholderStrategy: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="hardlink">hardlink</option>
                            <option value="copy">copy</option>
                            <option value="symlink">symlink</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>TV Play Mode</Typography>
                          <select
                            name="placeholdarr_tvPlayMode"
                            value={config.placeholdarrSettings.tvPlayMode}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, tvPlayMode: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="episode">episode</option>
                            <option value="season">season</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Title Updates</Typography>
                          <select
                            name="placeholdarr_titleUpdates"
                            value={config.placeholdarrSettings.titleUpdates}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, titleUpdates: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="ON">ON</option>
                            <option value="OFF">OFF</option>
                          </select>
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Include Specials</Typography>
                          <select
                            name="placeholdarr_includeSpecials"
                            value={config.placeholdarrSettings.includeSpecials ? 'true' : 'false'}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, includeSpecials: e.target.value === 'true' } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="false">False</option>
                            <option value="true">True</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Episodes Lookahead</Typography>
                          <input
                            type="number"
                            name="placeholdarr_episodesLookahead"
                            value={config.placeholdarrSettings.episodesLookahead}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, episodesLookahead: Number(e.target.value) } }))}
                            placeholder="0"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Max Monitor Time</Typography>
                          <input
                            type="number"
                            name="placeholdarr_maxMonitorTime"
                            value={config.placeholdarrSettings.maxMonitorTime}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, maxMonitorTime: Number(e.target.value) } }))}
                            placeholder="0"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Check Interval</Typography>
                          <input
                            type="number"
                            name="placeholdarr_checkInterval"
                            value={config.placeholdarrSettings.checkInterval}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, checkInterval: Number(e.target.value) } }))}
                            placeholder="0"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          />
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Available Cleanup Delay</Typography>
                          <input
                            type="number"
                            name="placeholdarr_availableCleanupDelay"
                            value={config.placeholdarrSettings.availableCleanupDelay}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, availableCleanupDelay: Number(e.target.value) } }))}
                            placeholder="0"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Calendar Lookahead Days</Typography>
                          <input
                            type="number"
                            name="placeholdarr_calendarLookaheadDays"
                            value={config.placeholdarrSettings.calendarLookaheadDays}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, calendarLookaheadDays: Number(e.target.value) } }))}
                            placeholder="0"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Calendar Sync Interval (Hours)</Typography>
                          <input
                            type="number"
                            name="placeholdarr_calendarSyncIntervalHours"
                            value={config.placeholdarrSettings.calendarSyncIntervalHours}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, calendarSyncIntervalHours: Number(e.target.value) } }))}
                            placeholder="0"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Enable Coming Soon Placeholders</Typography>
                          <select
                            name="placeholdarr_enableComingSoonPlaceholders"
                            value={config.placeholdarrSettings.enableComingSoonPlaceholders ? 'true' : 'false'}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, enableComingSoonPlaceholders: e.target.value === 'true' } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="false">False</option>
                            <option value="true">True</option>
                          </select>
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Preferred Movie Date Type</Typography>
                          <select
                            name="placeholdarr_preferredMovieDateType"
                            value={config.placeholdarrSettings.preferredMovieDateType}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, preferredMovieDateType: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="inCinemas">inCinemas</option>
                            <option value="physicalRelease">physicalRelease</option>
                            <option value="digitalRelease">digitalRelease</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Enable Coming Soon Countdown</Typography>
                          <select
                            name="placeholdarr_enableComingSoonCountdown"
                            value={config.placeholdarrSettings.enableComingSoonCountdown ? 'true' : 'false'}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, enableComingSoonCountdown: e.target.value === 'true' } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="false">False</option>
                            <option value="true">True</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Calendar Placeholder Mode</Typography>
                          <select
                            name="placeholdarr_calendarPlaceholderMode"
                            value={config.placeholdarrSettings.calendarPlaceholderMode}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, calendarPlaceholderMode: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="episode">episode</option>
                            <option value="season">season</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Coming Soon Dummy File Path</Typography>
                          <input
                            name="placeholdarr_comingSoonDummyFilePath"
                            value={config.placeholdarrSettings.comingSoonDummyFilePath}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, comingSoonDummyFilePath: e.target.value } }))}
                            placeholder="/data/media/comingsoon.mkv"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          />
                        </Box>
                      </Box>
                      {/* Legacy/advanced fields */}
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>API Key</Typography>
                          <input
                            name="placeholdarr_apiKey"
                            value={config.placeholdarrSettings.apiKey}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, apiKey: e.target.value } }))}
                            placeholder="surgestack"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Authentication Method</Typography>
                          <select
                            name="placeholdarr_authMethod"
                            value={config.placeholdarrSettings.authMethod}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, authMethod: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="Basic">Basic</option>
                            <option value="Forms">Forms</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Log Level</Typography>
                          <select
                            name="placeholdarr_logLevel"
                            value={config.placeholdarrSettings.logLevel}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, logLevel: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="Trace">Trace</option>
                            <option value="Debug">Debug</option>
                            <option value="Info">Info</option>
                            <option value="Warn">Warn</option>
                            <option value="Error">Error</option>
                            <option value="Fatal">Fatal</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Branch</Typography>
                          <input
                            name="placeholdarr_branch"
                            value={config.placeholdarrSettings.branch}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, branch: e.target.value } }))}
                            placeholder="master"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Launch Browser</Typography>
                          <select
                            name="placeholdarr_launchBrowser"
                            value={config.placeholdarrSettings.launchBrowser}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, launchBrowser: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="false">False</option>
                            <option value="true">True</option>
                          </select>
                        </Box>
                      </Box>
                    </Box>
                  ) : (
                    <Typography style={{ color: '#bbb', fontStyle: 'italic' }}>Settings for {service} will appear here.</Typography>
                  )}
                </Box>
              ))}
            </Box>
          )}
          {activeStep === 4 && (
            <Box>
              <Typography variant="h6" style={{ color: '#fff', marginBottom: 16 }}>External API Configuration</Typography>
              <Typography style={{ color: '#aaa', marginBottom: 24, fontSize: 14 }}>
                Configure external API keys to enhance your media server with metadata, artwork, and additional features. 
                These APIs improve the functionality of various services but are optional.
              </Typography>

              <Box display="grid" gridTemplateColumns="1fr" gap={3}>
                {/* Essential APIs */}
                <Box sx={{ border: '1px solid #07938f', borderRadius: 2, p: 3, background: '#0a2a2a' }}>
                  <Typography style={{ color: '#07938f', fontWeight: 'bold', marginBottom: 12, fontSize: 16 }}>
                    🎬 Essential APIs (Recommended)
                  </Typography>
                  
                  <Box display="flex" flexDirection="column" gap={2}>
                    <Box>
                      <Typography style={{ color: '#fff', marginBottom: 4 }}>
                        TMDB API Key <span style={{ color: '#07938f' }}>*Recommended</span>
                      </Typography>
                      <input
                        name="tmdbApiKey"
                        value={config.tmdbApiKey || ''}
                        onChange={(e) => setConfig(prev => ({ ...prev, tmdbApiKey: e.target.value }))}
                        placeholder="Enter your TMDB API key"
                        style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                      />
                      <Typography style={{ color: '#888', fontSize: 12, marginTop: 4 }}>
                        Get your free API key from <a href="https://www.themoviedb.org/settings/api" target="_blank" rel="noopener noreferrer" style={{ color: '#07938f' }}>TMDB</a>. 
                        Used by CineSync, Kometa, GAPS, and Posterizarr for movie/TV metadata.
                      </Typography>
                    </Box>

                    <Box>
                      <Typography style={{ color: '#fff', marginBottom: 4 }}>
                        Real-Debrid API Token
                      </Typography>
                      <input
                        name="rdApiToken"
                        value={config.rdApiToken || ''}
                        onChange={(e) => setConfig(prev => ({ ...prev, rdApiToken: e.target.value }))}
                        placeholder="Enter your Real-Debrid API token"
                        style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                      />
                      <Typography style={{ color: '#888', fontSize: 12, marginTop: 4 }}>
                        Get from <a href="https://real-debrid.com/apitoken" target="_blank" rel="noopener noreferrer" style={{ color: '#07938f' }}>Real-Debrid</a>. 
                        Required for Zurg, cli_debrid, and RDT-Client.
                      </Typography>
                    </Box>
                  </Box>
                </Box>

                {/* Enhanced Features APIs */}
                <Box sx={{ border: '1px solid #444', borderRadius: 2, p: 3, background: '#1a1a1a' }}>
                  <Typography style={{ color: '#fff', fontWeight: 'bold', marginBottom: 12, fontSize: 16 }}>
                    🎨 Enhanced Features (Optional)
                  </Typography>
                  
                  <Box display="flex" flexDirection="column" gap={2}>
                    <Box>
                      <Typography style={{ color: '#fff', marginBottom: 4 }}>
                        FanArt.tv API Key
                      </Typography>
                      <input
                        name="fanartApiKey"
                        value={config.fanartApiKey || ''}
                        onChange={(e) => setConfig(prev => ({ ...prev, fanartApiKey: e.target.value }))}
                        placeholder="Enter your FanArt.tv API key (optional)"
                        style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                      />
                      <Typography style={{ color: '#888', fontSize: 12, marginTop: 4 }}>
                        Get from <a href="https://fanart.tv/get-an-api-key/" target="_blank" rel="noopener noreferrer" style={{ color: '#888' }}>FanArt.tv</a>. 
                        Provides high-quality artwork for Posterizarr and Kometa.
                      </Typography>
                    </Box>

                    <Box>
                      <Typography style={{ color: '#fff', marginBottom: 4 }}>
                        TVDB API Key
                      </Typography>
                      <input
                        name="tvdbApiKey"
                        value={config.tvdbApiKey || ''}
                        onChange={(e) => setConfig(prev => ({ ...prev, tvdbApiKey: e.target.value }))}
                        placeholder="Enter your TVDB API key (optional)"
                        style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                      />
                      <Typography style={{ color: '#888', fontSize: 12, marginTop: 4 }}>
                        Enhanced TV show metadata. Register at <a href="https://thetvdb.com/api-information" target="_blank" rel="noopener noreferrer" style={{ color: '#888' }}>TVDB</a>.
                      </Typography>
                    </Box>

                    <Box>
                      <Typography style={{ color: '#fff', marginBottom: 4 }}>
                        Trakt API Key
                      </Typography>
                      <input
                        name="traktApiKey"
                        value={config.traktApiKey || ''}
                        onChange={(e) => setConfig(prev => ({ ...prev, traktApiKey: e.target.value }))}
                        placeholder="Enter your Trakt API key (optional)"
                        style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                      />
                      <Typography style={{ color: '#888', fontSize: 12, marginTop: 4 }}>
                        For watchlist sync and recommendations. Get from <a href="https://trakt.tv/oauth/applications" target="_blank" rel="noopener noreferrer" style={{ color: '#888' }}>Trakt</a>.
                      </Typography>
                    </Box>
                  </Box>
                </Box>

                {/* Alternative Debrid Services */}
                <Box sx={{ border: '1px solid #333', borderRadius: 2, p: 3, background: '#151515' }}>
                  <Typography style={{ color: '#fff', fontWeight: 'bold', marginBottom: 12, fontSize: 16 }}>
                    🔄 Alternative Debrid Services (Optional)
                  </Typography>
                  
                  <Box display="flex" flexDirection="column" gap={2}>
                    <Box>
                      <Typography style={{ color: '#fff', marginBottom: 4 }}>
                        AllDebrid API Token
                      </Typography>
                      <input
                        name="adApiToken"
                        value={config.adApiToken || ''}
                        onChange={(e) => setConfig(prev => ({ ...prev, adApiToken: e.target.value }))}
                        placeholder="Enter your AllDebrid API token (optional)"
                        style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                      />
                      <Typography style={{ color: '#888', fontSize: 12, marginTop: 4 }}>
                        Alternative to Real-Debrid. Get from <a href="https://alldebrid.com/account/" target="_blank" rel="noopener noreferrer" style={{ color: '#888' }}>AllDebrid</a>.
                      </Typography>
                    </Box>

                    <Box>
                      <Typography style={{ color: '#fff', marginBottom: 4 }}>
                        Premiumize API Token
                      </Typography>
                      <input
                        name="premiumizeApiToken"
                        value={config.premiumizeApiToken || ''}
                        onChange={(e) => setConfig(prev => ({ ...prev, premiumizeApiToken: e.target.value }))}
                        placeholder="Enter your Premiumize API token (optional)"
                        style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                      />
                      <Typography style={{ color: '#888', fontSize: 12, marginTop: 4 }}>
                        Alternative debrid service. Get from <a href="https://www.premiumize.me/account" target="_blank" rel="noopener noreferrer" style={{ color: '#888' }}>Premiumize</a>.
                      </Typography>
                    </Box>
                  </Box>
                </Box>
              </Box>

              <Box mt={3} p={2} sx={{ background: '#0a1a2a', border: '1px solid #1a4a5a', borderRadius: 2 }}>
                <Typography style={{ color: '#79eaff', fontWeight: 'bold', marginBottom: 8, fontSize: 14 }}>
                  💡 Pro Tips:
                </Typography>
                <ul style={{ color: '#aaa', fontSize: 12, margin: 0, paddingLeft: 16 }}>
                  <li>TMDB API is free and greatly improves metadata quality</li>
                  <li>Real-Debrid enables premium streaming and fast downloads</li>
                  <li>All API keys are stored securely and never shared</li>
                  <li>You can add or change API keys later in the configuration files</li>
                </ul>
              </Box>
            </Box>
          )}
          {activeStep === 5 && (
            <Box>
              <Typography variant="h6" style={{ color: '#fff', marginBottom: 16 }}>Download Clients & Tools</Typography>
              <Box display="flex" gap={3} mb={3} justifyContent="center">
                {downloadToolsList.map((tool) => (
                  <Tooltip key={tool.key} title={tool.desc} placement="top">
                    <Box
                      onClick={() => setDownloadTools((prev) => ({ ...prev, [tool.key]: !prev[tool.key] }))}
                      sx={{
                        cursor: 'pointer',
                        opacity: downloadTools[tool.key] ? 1 : 0.4,
                        filter: downloadTools[tool.key] ? 'none' : 'grayscale(100%)',
                        border: downloadTools[tool.key] ? '2px solid #07938f' : '2px solid #444',
                        borderRadius: 2,
                        p: 1,
                        background: '#181818',
                        transition: 'all 0.2s',
                        position: 'relative',
                        boxShadow: downloadTools[tool.key] ? '0 0 8px #07938f' : 'none',
                        '&:hover': { boxShadow: '0 0 16px #07938f' }
                      }}
                    >
                      <img src={tool.logo} alt={tool.name} style={{ width: 64, height: 64, display: 'block', margin: '0 auto' }} />
                      <Typography align="center" style={{ color: '#fff', fontSize: 14, marginTop: 4 }}>{tool.name}</Typography>
                      {!downloadTools[tool.key] && (
                        <Box sx={{
                          position: 'absolute',
                          top: 0,
                          left: 0,
                          width: '100%',
                          height: '100%',
                          bgcolor: 'rgba(40,40,40,0.6)',
                          borderRadius: 2
                        }} />
                      )}
                    </Box>
                  </Tooltip>
                ))}
              </Box>
              {/* Sub-sections for enabled download tools */}
              {downloadToolsList.filter((tool) => downloadTools[tool.key]).map((tool) => (
                <Box key={tool.key} sx={{ background: '#232323', borderRadius: 2, p: 0, mb: 2, mt: 2, border: '2px solid #07938f' }}>
                  <Typography variant="subtitle1" style={{ color: '#fff', fontWeight: 600, marginBottom: 8 }}>{tool.name}</Typography>
                  {/* NZBGet fields */}
              {tool.key === 'nzbget' && (
                <Box display="flex" flexDirection="column" gap={2}>
                  <Box display="flex" gap={2}>
                    <Box flex={1}>
                      <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                        Host/URL
                        <Tooltip title="The URL or IP address where NZBGet is accessible (e.g. http://nzbget:6789).">
                          <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                          </span>
                        </Tooltip>
                      </Typography>
                      <input
                        name="nzbget_url"
                        value={config.nzbgetUrl || ''}
                        onChange={e => setConfig(prev => ({ ...prev, nzbgetUrl: e.target.value }))}
                        placeholder="http://nzbget:6789"
                        style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                      />
                    </Box>
                    <Box flex={1}>
                      <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                        Port
                        <Tooltip title="The port NZBGet listens on (default: 6789).">
                          <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                          </span>
                        </Tooltip>
                      </Typography>
                      <input
                        name="nzbget_port"
                        value={config.nzbgetPort || ''}
                        onChange={e => setConfig(prev => ({ ...prev, nzbgetPort: e.target.value }))}
                        placeholder="6789"
                        style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                      />
                    </Box>
                    <Box flex={1}>
                      <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                        SSL/TLS
                        <Tooltip title="Enable SSL/TLS for secure NZBGet access.">
                          <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                          </span>
                        </Tooltip>
                      </Typography>
                      <select
                        name="nzbget_ssl"
                        value={config.nzbgetSsl || 'false'}
                        onChange={e => setConfig(prev => ({ ...prev, nzbgetSsl: e.target.value }))}
                        style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                      >
                        <option value="false">False</option>
                        <option value="true">True</option>
                      </select>
                    </Box>
                  </Box>
                  <Box display="flex" gap={2}>
                    <Box flex={1}>
                      <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                        Username
                        <Tooltip title="Username for NZBGet web interface.">
                          <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                          </span>
                        </Tooltip>
                      </Typography>
                      <input
                        name="nzbget_username"
                        value={config.nzbgetUsername || ''}
                        onChange={e => setConfig(prev => ({ ...prev, nzbgetUsername: e.target.value }))}
                        placeholder="admin"
                        style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                      />
                    </Box>
                    <Box flex={1}>
                      <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                        Password
                        <Tooltip title="Password for NZBGet web interface.">
                          <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                          </span>
                        </Tooltip>
                      </Typography>
                      <input
                        name="nzbget_password"
                        type="password"
                        value={config.nzbgetPassword || ''}
                        onChange={e => setConfig(prev => ({ ...prev, nzbgetPassword: e.target.value }))}
                        placeholder="surge"
                        style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                      />
                    </Box>
                    <Box flex={1}>
                      <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                        API Key
                        <Tooltip title="API key for NZBGet RPC access (if set).">
                          <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                          </span>
                        </Tooltip>
                      </Typography>
                      <input
                        name="nzbget_apikey"
                        value={config.nzbgetApiKey || ''}
                        onChange={e => setConfig(prev => ({ ...prev, nzbgetApiKey: e.target.value }))}
                        placeholder="surgestack"
                        style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                      />
                    </Box>
                  </Box>
                  <Box display="flex" gap={2}>
                    <Box flex={1}>
                      <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                        Destination Directory
                        <Tooltip title="Directory where NZBGet will save downloads.">
                          <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                          </span>
                        </Tooltip>
                      </Typography>
                      <input
                        name="nzbget_destinationDirectory"
                        value={config.nzbgetDestinationDirectory || ''}
                        onChange={e => setConfig(prev => ({ ...prev, nzbgetDestinationDirectory: e.target.value }))}
                        placeholder="/opt/surge/NZBGet/Downloads"
                        style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                      />
                    </Box>
                  </Box>
                </Box>
                  )}
                  {/* RDT-Client fields */}
                  {tool.key === 'rdtclient' && (
                    <Box display="flex" flexDirection="column" gap={2}>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Host/URL
                            <Tooltip title="The URL or IP address where RDT-Client is accessible (e.g. http://rdtclient:6500).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="rdtclient_url"
                            value={config.rdtClientUrl || ''}
                            onChange={e => setConfig(prev => ({ ...prev, rdtClientUrl: e.target.value }))}
                            placeholder="http://rdtclient:6500"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Port
                            <Tooltip title="The port RDT-Client listens on (default: 6500).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="rdtclient_port"
                            value={config.rdtClientPort || ''}
                            onChange={e => setConfig(prev => ({ ...prev, rdtClientPort: e.target.value }))}
                            placeholder="6500"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            API Key
                            <Tooltip title="API key for RDT-Client access.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="rdtclient_apikey"
                            value={config.rdtClientApiKey || ''}
                            onChange={e => setConfig(prev => ({ ...prev, rdtClientApiKey: e.target.value }))}
                            placeholder="API Key"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Username
                            <Tooltip title="Username for RDT-Client web interface.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="rdtclient_username"
                            value={config.rdtClientUsername || ''}
                            onChange={e => setConfig(prev => ({ ...prev, rdtClientUsername: e.target.value }))}
                            placeholder="username"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Password
                            <Tooltip title="Password for RDT-Client web interface.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="rdtclient_password"
                            type="password"
                            value={config.rdtClientPassword || ''}
                            onChange={e => setConfig(prev => ({ ...prev, rdtClientPassword: e.target.value }))}
                            placeholder="password"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Download Path
                            <Tooltip title="Path where RDT-Client will save downloads.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="rdtclient_downloadPath"
                            value={config.rdtClientDownloadPath || ''}
                            onChange={e => setConfig(prev => ({ ...prev, rdtClientDownloadPath: e.target.value }))}
                            placeholder="/downloads"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                      </Box>
                    </Box>
                  )}
                  {/* GAPS fields */}
                  {tool.key === 'gaps' && (
                    <Box display="flex" flexDirection="column" gap={2}>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Host/URL
                            <Tooltip title="The URL or IP address where GAPS is accessible (e.g. http://gaps:8484).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="gaps_url"
                            value={config.gapsUrl || ''}
                            onChange={e => setConfig(prev => ({ ...prev, gapsUrl: e.target.value }))}
                            placeholder="http://gaps:8484"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            API Key
                            <Tooltip title="API key for GAPS access.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="gaps_apikey"
                            value={config.gapsApiKey || ''}
                            onChange={e => setConfig(prev => ({ ...prev, gapsApiKey: e.target.value }))}
                            placeholder="API Key"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Radarr URL
                            <Tooltip title="The URL for your Radarr instance used by GAPS.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="gaps_radarrUrl"
                            value={config.gapsRadarrUrl || ''}
                            onChange={e => setConfig(prev => ({ ...prev, gapsRadarrUrl: e.target.value }))}
                            placeholder="http://radarr:7878"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Radarr API Key
                            <Tooltip title="API key for your Radarr instance used by GAPS.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="gaps_radarrApiKey"
                            value={config.gapsRadarrApiKey || ''}
                            onChange={e => setConfig(prev => ({ ...prev, gapsRadarrApiKey: e.target.value }))}
                            placeholder="Radarr API Key"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                      </Box>
                    </Box>
                  )}
                  {/* Zurg fields */}
                  {tool.key === 'zurg' && (
                    <Box display="flex" flexDirection="column" gap={2}>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Host/URL
                            <Tooltip title="The URL or IP address where Zurg is accessible (e.g. http://zurg:9000).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="zurg_url"
                            value={config.zurgUrl || ''}
                            onChange={e => setConfig(prev => ({ ...prev, zurgUrl: e.target.value }))}
                            placeholder="http://zurg:9000"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Token
                            <Tooltip title="Your Real-Debrid token for Zurg (required).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="zurg_token"
                            value={config.zurgToken || ''}
                            onChange={e => setConfig(prev => ({ ...prev, zurgToken: e.target.value }))}
                            placeholder="Real-Debrid Token"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Download Path
                            <Tooltip title="Path where Zurg will save downloads.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="zurg_downloadPath"
                            value={config.zurgDownloadPath || ''}
                            onChange={e => setConfig(prev => ({ ...prev, zurgDownloadPath: e.target.value }))}
                            placeholder="/downloads"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Host
                            <Tooltip title="Bind address for Zurg (default: [::]).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="zurg_host"
                            value={config.zurgHost || ''}
                            onChange={e => setConfig(prev => ({ ...prev, zurgHost: e.target.value }))}
                            placeholder="[::]"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Port
                            <Tooltip title="Port for Zurg web server (default: 9999).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="zurg_port"
                            value={config.zurgPort || ''}
                            onChange={e => setConfig(prev => ({ ...prev, zurgPort: e.target.value }))}
                            placeholder="9999"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Username
                            <Tooltip title="Optional HTTP username for Zurg UI.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="zurg_username"
                            value={config.zurgUsername || ''}
                            onChange={e => setConfig(prev => ({ ...prev, zurgUsername: e.target.value }))}
                            placeholder="Username"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Password
                            <Tooltip title="Optional HTTP password for Zurg UI.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="zurg_password"
                            value={config.zurgPassword || ''}
                            onChange={e => setConfig(prev => ({ ...prev, zurgPassword: e.target.value }))}
                            placeholder="Password"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                      </Box>
                      {/* Advanced Config Toggle */}
                      <Box mt={2}>
                        <Button
                          variant="outlined"
                          style={{ color: '#fff', borderColor: '#07938f', marginBottom: 8 }}
                          onClick={() => setShowZurgAdvanced(prev => !prev)}
                        >
                          {showZurgAdvanced ? 'Hide Advanced Config' : 'Show Advanced Config'}
                        </Button>
                        {showZurgAdvanced && (
                          <Box display="flex" flexDirection="column" gap={2} sx={{ background: '#232323', borderRadius: 2, p: 2, border: '1px solid #07938f' }}>
                            <Box display="flex" gap={2}>
                              <Box flex={1}>
                                <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                                  Proxy
                                  <Tooltip title="Proxy settings (YAML or string, advanced).">
                                    <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                                    </span>
                                  </Tooltip>
                                </Typography>
                                <input
                                  name="zurg_proxy"
                                  value={config.zurgProxy || ''}
                                  onChange={e => setConfig(prev => ({ ...prev, zurgProxy: e.target.value }))}
                                  placeholder="Proxy config (advanced)"
                                  style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                                />
                              </Box>
                              <Box flex={1}>
                                <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                                  Concurrent Workers
                                  <Tooltip title="Number of concurrent workers (advanced).">
                                    <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                                    </span>
                                  </Tooltip>
                                </Typography>
                                <input
                                  name="zurg_concurrentWorkers"
                                  value={config.zurgConcurrentWorkers || ''}
                                  onChange={e => setConfig(prev => ({ ...prev, zurgConcurrentWorkers: e.target.value }))}
                                  placeholder="20"
                                  style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                                />
                              </Box>
                              <Box flex={1}>
                                <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                                  Check for Changes (secs)
                                  <Tooltip title="How often to check for changes (seconds, advanced).">
                                    <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                                    </span>
                                  </Tooltip>
                                </Typography>
                                <input
                                  name="zurg_checkForChangesEverySecs"
                                  value={config.zurgCheckForChangesEverySecs || ''}
                                  onChange={e => setConfig(prev => ({ ...prev, zurgCheckForChangesEverySecs: e.target.value }))}
                                  placeholder="10"
                                  style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                                />
                              </Box>
                            </Box>
                            {/* Add more advanced fields as needed, following the same pattern */}
                          </Box>
                        )}
                      </Box>
                    </Box>
                  )}
                  {/* Decypharr fields */}
                  {tool.key === 'decypharr' && (
                    <Box display="flex" flexDirection="column" gap={2}>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Host/URL
                            <Tooltip title="The URL or IP address where Decypharr is accessible (e.g. http://decypharr:8282).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="decypharr_url"
                            value={config.decypharrUrl || ''}
                            onChange={e => setConfig(prev => ({ ...prev, decypharrUrl: e.target.value }))}
                            placeholder="http://decypharr:8282"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            API Key
                            <Tooltip title="API key for Decypharr access.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="decypharr_apikey"
                            value={config.decypharrApiKey || ''}
                            onChange={e => setConfig(prev => ({ ...prev, decypharrApiKey: e.target.value }))}
                            placeholder="API Key"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Download Folder
                            <Tooltip title="Folder where Decypharr will place downloads or symlinks.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="decypharr_downloadFolder"
                            value={config.decypharrDownloadFolder || ''}
                            onChange={e => setConfig(prev => ({ ...prev, decypharrDownloadFolder: e.target.value }))}
                            placeholder="/mnt/symlinks/"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Categories
                            <Tooltip title="Categories for Arr integration (comma separated, e.g. sonarr,radarr)">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="decypharr_categories"
                            value={config.decypharrCategories || ''}
                            onChange={e => setConfig(prev => ({ ...prev, decypharrCategories: e.target.value }))}
                            placeholder="sonarr,radarr"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Use Auth
                            <Tooltip title="Enable authentication for Decypharr UI.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name="decypharr_useAuth"
                            value={config.decypharrUseAuth ? 'true' : 'false'}
                            onChange={e => setConfig(prev => ({ ...prev, decypharrUseAuth: e.target.value === 'true' }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="false">False</option>
                            <option value="true">True</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Port
                            <Tooltip title="Port for Decypharr web server (default: 8282).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="decypharr_port"
                            type="number"
                            value={config.decypharrPort || 8282}
                            onChange={e => setConfig(prev => ({ ...prev, decypharrPort: Number(e.target.value) }))}
                            placeholder="8282"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Log Level
                            <Tooltip title="Verbosity of logs written by Decypharr.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name="decypharr_logLevel"
                            value={config.decypharrLogLevel || 'info'}
                            onChange={e => setConfig(prev => ({ ...prev, decypharrLogLevel: e.target.value }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="debug">Debug</option>
                            <option value="info">Info</option>
                            <option value="warn">Warn</option>
                            <option value="error">Error</option>
                            <option value="trace">Trace</option>
                          </select>
                        </Box>
                      </Box>
                      {/* Advanced Config Toggle */}
                      <Box mt={2}>
                        <Button
                          variant="outlined"
                          style={{ color: '#fff', borderColor: '#07938f', marginBottom: 8 }}
                          onClick={() => setShowDecypharrAdvanced(prev => !prev)}
                        >
                          {showDecypharrAdvanced ? 'Hide Advanced Config' : 'Show Advanced Config'}
                        </Button>
                        {showDecypharrAdvanced && (
                          <Box display="flex" flexDirection="column" gap={2} sx={{ background: '#232323', borderRadius: 2, p: 2, border: '1px solid #07938f' }}>
                            <Box display="flex" gap={2}>
                              <Box flex={1}>
                                <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                                  Discord Webhook URL
                                  <Tooltip title="Webhook for Discord notifications.">
                                    <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                                    </span>
                                  </Tooltip>
                                </Typography>
                                <input
                                  name="decypharr_discordWebhookUrl"
                                  value={config.decypharrDiscordWebhookUrl || ''}
                                  onChange={e => setConfig(prev => ({ ...prev, decypharrDiscordWebhookUrl: e.target.value }))}
                                  placeholder="https://discord.com/api/webhooks/..."
                                  style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                                />
                              </Box>
                              <Box flex={1}>
                                <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                                  Min File Size (bytes)
                                  <Tooltip title="Minimum file size to process (bytes).">
                                    <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                                    </span>
                                  </Tooltip>
                                </Typography>
                                <input
                                  name="decypharr_minFileSize"
                                  type="number"
                                  value={config.decypharrMinFileSize || ''}
                                  onChange={e => setConfig(prev => ({ ...prev, decypharrMinFileSize: e.target.value }))}
                                  placeholder="0"
                                  style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                                />
                              </Box>
                              <Box flex={1}>
                                <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                                  Max File Size (bytes)
                                  <Tooltip title="Maximum file size to process (bytes).">
                                    <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                                    </span>
                                  </Tooltip>
                                </Typography>
                                <input
                                  name="decypharr_maxFileSize"
                                  type="number"
                                  value={config.decypharrMaxFileSize || ''}
                                  onChange={e => setConfig(prev => ({ ...prev, decypharrMaxFileSize: e.target.value }))}
                                  placeholder="0"
                                  style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                                />
                              </Box>
                              <Box flex={1}>
                                <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                                  Allowed File Types
                                  <Tooltip title="Allowed file extensions (comma separated, e.g. mp4,mkv,avi)">
                                    <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                                    </span>
                                  </Tooltip>
                                </Typography>
                                <input
                                  name="decypharr_allowedFileTypes"
                                  value={config.decypharrAllowedFileTypes || ''}
                                  onChange={e => setConfig(prev => ({ ...prev, decypharrAllowedFileTypes: e.target.value }))}
                                  placeholder="mp4,mkv,avi"
                                  style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                                />
                              </Box>
                            </Box>
                            {/* Add more advanced fields as needed, following the same pattern */}
                          </Box>
                        )}
                      </Box>
                    </Box>
                  )}
                </Box>
              ))}
            </Box>
          )}
          {activeStep === 5 && (
            <Box>
              <Typography variant="h6" style={{ color: '#fff', marginBottom: 16 }}>Content Enhancement</Typography>
              <Box display="flex" gap={3} mb={3} justifyContent="center">
                {contentEnhancementList.map((tool) => (
                  <Tooltip key={tool.key} title={tool.desc} placement="top">
                    <Box
                      onClick={() => setContentEnhancement((prev) => ({ ...prev, [tool.key]: !prev[tool.key] }))}
                      sx={{
                        cursor: 'pointer',
                        opacity: contentEnhancement[tool.key] ? 1 : 0.4,
                        filter: contentEnhancement[tool.key] ? 'none' : 'grayscale(100%)',
                        border: contentEnhancement[tool.key] ? '2px solid #07938f' : '2px solid #444',
                        borderRadius: 2,
                        p: 1,
                        background: '#181818',
                        transition: 'all 0.2s',
                        position: 'relative',
                        boxShadow: contentEnhancement[tool.key] ? '0 0 8px #07938f' : 'none',
                        '&:hover': { boxShadow: '0 0 16px #07938f' }
                      }}
                    >
                      <img src={tool.logo} alt={tool.name} style={{ width: 64, height: 64, display: 'block', margin: '0 auto' }} />
                      <Typography align="center" style={{ color: '#fff', fontSize: 14, marginTop: 4 }}>{tool.name}</Typography>
                      {!contentEnhancement[tool.key] && (
                        <Box sx={{
                          position: 'absolute',
                          top: 0,
                          left: 0,
                          width: '100%',
                          height: '100%',
                          bgcolor: 'rgba(40,40,40,0.6)',
                          borderRadius: 2
                        }} />
                      )}
                    </Box>
                  </Tooltip>
                ))}
              </Box>
              {/* Sub-sections for enabled content enhancement tools */}
              {/* Kometa */}
              {contentEnhancement.kometa && (
                <Box sx={{ background: '#232323', borderRadius: 2, p: 2, mb: 2, mt: 2, border: '2px solid #07938f' }}>
                  <Typography variant="subtitle1" style={{ color: '#fff', fontWeight: 600, marginBottom: 8 }}>Kometa</Typography>
                  <Button variant="outlined" size="small" sx={{ mb: 2, color: '#fff', borderColor: '#07938f' }} onClick={() => setShowKometaAdvanced((v) => !v)}>
                    {showKometaAdvanced ? 'Hide Advanced Config' : 'Show Advanced Config'}
                  </Button>
                  <Box display="flex" gap={2} alignItems="center">
                    <Typography style={{ color: '#fff' }}>Kometa URL</Typography>
                    <input
                      name="kometaUrl"
                      value={config.kometaUrl}
                      onChange={handleChange}
                      placeholder="http://kometa:8000"
                      style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                    />
                  </Box>
                  <Box display="flex" gap={2} alignItems="center" mt={2}>
                    <Typography style={{ color: '#fff' }}>Kometa API Key</Typography>
                    <input
                      name="kometaApiKey"
                      value={config.kometaApiKey}
                      onChange={handleChange}
                      placeholder="API Key"
                      style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                    />
                  </Box>
                  {showKometaAdvanced && (
                    <Box mt={2}>
                      <Typography style={{ color: '#fff', fontWeight: 500, marginBottom: 8 }}>Advanced Kometa Options</Typography>
                      <Box display="flex" gap={2} alignItems="center" mb={2}>
                        <Typography style={{ color: '#fff' }}>Config Path</Typography>
                        <input
                          name="kometaSettings.CONFIG_PATH"
                          value={config.kometaSettings?.CONFIG_PATH || ''}
                          onChange={e => setConfig(prev => ({ ...prev, kometaSettings: { ...prev.kometaSettings, CONFIG_PATH: e.target.value } }))}
                          placeholder="/config/config.yml"
                          style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                        />
                      </Box>
                      <Box display="flex" gap={2} alignItems="center" mb={2}>
                        <Typography style={{ color: '#fff' }}>Log Level</Typography>
                        <select
                          name="kometaSettings.LOG_LEVEL"
                          value={config.kometaSettings?.LOG_LEVEL || 'info'}
                          onChange={e => setConfig(prev => ({ ...prev, kometaSettings: { ...prev.kometaSettings, LOG_LEVEL: e.target.value } }))}
                          style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                        >
                          <option value="info">Info</option>
                          <option value="debug">Debug</option>
                          <option value="warning">Warning</option>
                          <option value="error">Error</option>
                        </select>
                      </Box>
                      <Box display="flex" gap={2} alignItems="center" mb={2}>
                        <Typography style={{ color: '#fff' }}>Timezone (TZ)</Typography>
                        <input
                          name="kometaSettings.TZ"
                          value={config.kometaSettings?.TZ || ''}
                          onChange={e => setConfig(prev => ({ ...prev, kometaSettings: { ...prev.kometaSettings, TZ: e.target.value } }))}
                          placeholder="UTC"
                          style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                        />
                      </Box>
                      <Box display="flex" gap={2} alignItems="center" mb={2}>
                        <Typography style={{ color: '#fff' }}>Extra Env</Typography>
                        <input
                          name="kometaSettings.extra_env"
                          value={config.kometaSettings?.extra_env || ''}
                          onChange={e => setConfig(prev => ({ ...prev, kometaSettings: { ...prev.kometaSettings, extra_env: e.target.value } }))}
                          placeholder="{}"
                          style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                        />
                      </Box>
                      <Box display="flex" gap={2} alignItems="center" mb={2}>
                        <Typography style={{ color: '#fff' }}>Extra Args</Typography>
                        <input
                          name="kometaSettings.extra_args"
                          value={config.kometaSettings?.extra_args || ''}
                          onChange={e => setConfig(prev => ({ ...prev, kometaSettings: { ...prev.kometaSettings, extra_args: e.target.value } }))}
                          placeholder=""
                          style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                        />
                      </Box>
                    </Box>
                  )}
                </Box>
              )}
              {/* Posterizarr */}
              {contentEnhancement.posterizarr && (
                <Box sx={{ background: '#232323', borderRadius: 2, p: 2, mb: 2, mt: 2, border: '2px solid #07938f' }}>
                  <Typography variant="subtitle1" style={{ color: '#fff', fontWeight: 600, marginBottom: 8 }}>Posterizarr</Typography>
                  <Button variant="outlined" size="small" sx={{ mb: 2, color: '#fff', borderColor: '#07938f' }} onClick={() => setShowPosterizarrAdvanced((v) => !v)}>
                    {showPosterizarrAdvanced ? 'Hide Advanced Config' : 'Show Advanced Config'}
                  </Button>
                  <Box display="flex" gap={2} alignItems="center">
                    <Typography style={{ color: '#fff' }}>Posterizarr URL</Typography>
                    <input
                      name="posterizarrUrl"
                      value={config.posterizarrUrl}
                      onChange={handleChange}
                      placeholder="http://posterizarr:8000"
                      style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                    />
                  </Box>
                  <Box display="flex" gap={2} alignItems="center" mt={2}>
                    <Typography style={{ color: '#fff' }}>Posterizarr API Key</Typography>
                    <input
                      name="posterizarrApiKey"
                      value={config.posterizarrApiKey}
                      onChange={handleChange}
                      placeholder="API Key"
                      style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                    />
                  </Box>
                  {showPosterizarrAdvanced && (
                    <Box mt={2}>
                      <Typography style={{ color: '#fff', fontWeight: 500, marginBottom: 8 }}>Advanced Posterizarr Options</Typography>
                      <Box display="flex" gap={2} alignItems="center" mb={2}>
                        <Typography style={{ color: '#fff' }}>Config Path</Typography>
                        <input
                          name="posterizarrSettings.config_path"
                          value={config.posterizarrSettings?.config_path || ''}
                          onChange={e => setConfig(prev => ({ ...prev, posterizarrSettings: { ...prev.posterizarrSettings, config_path: e.target.value } }))}
                          placeholder="/config/config.json"
                          style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                        />
                      </Box>
                      <Box display="flex" gap={2} alignItems="center" mb={2}>
                        <Typography style={{ color: '#fff' }}>Run Time</Typography>
                        <input
                          name="posterizarrSettings.RUN_TIME"
                          value={config.posterizarrSettings?.RUN_TIME || ''}
                          onChange={e => setConfig(prev => ({ ...prev, posterizarrSettings: { ...prev.posterizarrSettings, RUN_TIME: e.target.value } }))}
                          placeholder="disabled"
                          style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                        />
                      </Box>
                      <Box display="flex" gap={2} alignItems="center" mb={2}>
                        <Typography style={{ color: '#fff' }}>Timezone (TZ)</Typography>
                        <input
                          name="posterizarrSettings.TZ"
                          value={config.posterizarrSettings?.TZ || ''}
                          onChange={e => setConfig(prev => ({ ...prev, posterizarrSettings: { ...prev.posterizarrSettings, TZ: e.target.value } }))}
                          placeholder="UTC"
                          style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                        />
                      </Box>
                      {/* Add more advanced Posterizarr options here as needed, matching backend */}
                      <Box display="flex" gap={2} alignItems="center" mb={2}>
                        <Typography style={{ color: '#fff' }}>Extra Env</Typography>
                        <input
                          name="posterizarrSettings.extra_env"
                          value={config.posterizarrSettings?.extra_env || ''}
                          onChange={e => setConfig(prev => ({ ...prev, posterizarrSettings: { ...prev.posterizarrSettings, extra_env: e.target.value } }))}
                          placeholder="{}"
                          style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                        />
                      </Box>
                      <Box display="flex" gap={2} alignItems="center" mb={2}>
                        <Typography style={{ color: '#fff' }}>Extra Args</Typography>
                        <input
                          name="posterizarrSettings.extra_args"
                          value={config.posterizarrSettings?.extra_args || ''}
                          onChange={e => setConfig(prev => ({ ...prev, posterizarrSettings: { ...prev.posterizarrSettings, extra_args: e.target.value } }))}
                          placeholder=""
                          style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                        />
                      </Box>
                    </Box>
                  )}
                </Box>
              )}
              {/* TODO: Add advanced config UI for Placeholdarr, NZBGet, RDT-Client, Gaps, cli-debrid, ImageMaid, CineSync, Zurg, Decypharr, etc. */}
              {/* Placeholdarr */}
              {contentEnhancement.placeholdarr && (
                <Box sx={{ background: '#232323', borderRadius: 2, p: 2, mb: 2, mt: 2, border: '2px solid #07938f' }}>
                  <Typography variant="subtitle1" style={{ color: '#fff', fontWeight: 600, marginBottom: 8 }}>Placeholdarr</Typography>
                  <Button variant="outlined" size="small" sx={{ mb: 2, color: '#fff', borderColor: '#07938f' }} onClick={() => setShowPlaceholdarrAdvanced((v) => !v)}>
                    {showPlaceholdarrAdvanced ? 'Hide Advanced Config' : 'Show Advanced Config'}
                  </Button>
                  {/* Basic fields */}
                  <Box display="flex" gap={2} alignItems="center">
                    <Typography style={{ color: '#fff' }}>Plex URL</Typography>
                    <input name="placeholdarrSettings.PLEX_URL" value={config.placeholdarrSettings?.PLEX_URL || ''} onChange={handleChange} placeholder="http://plex:32400" style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                  </Box>
                  <Box display="flex" gap={2} alignItems="center" mt={2}>
                    <Typography style={{ color: '#fff' }}>Plex Token</Typography>
                    <input name="placeholdarrSettings.PLEX_TOKEN" value={config.placeholdarrSettings?.PLEX_TOKEN || ''} onChange={handleChange} placeholder="Token" style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                  </Box>
                  {/* Advanced fields */}
                  {showPlaceholdarrAdvanced && (
                    <Box mt={2}>
                      <Typography style={{ color: '#fff', fontWeight: 500, marginBottom: 8 }}>Advanced Placeholdarr Options</Typography>
                      <Box display="flex" gap={2} alignItems="center" mb={2}>
                        <Typography style={{ color: '#fff' }}>Radarr URL</Typography>
                        <input name="placeholdarrSettings.RADARR_URL" value={config.placeholdarrSettings?.RADARR_URL || ''} onChange={handleChange} placeholder="http://radarr:7878" style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                      </Box>
                      <Box display="flex" gap={2} alignItems="center" mb={2}>
                        <Typography style={{ color: '#fff' }}>Radarr API Key</Typography>
                        <input name="placeholdarrSettings.RADARR_API_KEY" value={config.placeholdarrSettings?.RADARR_API_KEY || ''} onChange={handleChange} placeholder="API Key" style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                      </Box>
                      <Box display="flex" gap={2} alignItems="center" mb={2}>
                        <Typography style={{ color: '#fff' }}>Sonarr URL</Typography>
                        <input name="placeholdarrSettings.SONARR_URL" value={config.placeholdarrSettings?.SONARR_URL || ''} onChange={handleChange} placeholder="http://sonarr:8989" style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                      </Box>
                      <Box display="flex" gap={2} alignItems="center" mb={2}>
                        <Typography style={{ color: '#fff' }}>Sonarr API Key</Typography>
                        <input name="placeholdarrSettings.SONARR_API_KEY" value={config.placeholdarrSettings?.SONARR_API_KEY || ''} onChange={handleChange} placeholder="API Key" style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                      </Box>
                      <Box display="flex" gap={2} alignItems="center" mb={2}>
                        <Typography style={{ color: '#fff' }}>Movie Library Folder</Typography>
                        <input name="placeholdarrSettings.MOVIE_LIBRARY_FOLDER" value={config.placeholdarrSettings?.MOVIE_LIBRARY_FOLDER || ''} onChange={handleChange} placeholder="/data/movies" style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                      </Box>
                      <Box display="flex" gap={2} alignItems="center" mb={2}>
                        <Typography style={{ color: '#fff' }}>TV Library Folder</Typography>
                        <input name="placeholdarrSettings.TV_LIBRARY_FOLDER" value={config.placeholdarrSettings?.TV_LIBRARY_FOLDER || ''} onChange={handleChange} placeholder="/data/tv" style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                      </Box>
                      <Box display="flex" gap={2} alignItems="center" mb={2}>
                        <Typography style={{ color: '#fff' }}>Dummy File Path</Typography>
                        <input name="placeholdarrSettings.DUMMY_FILE_PATH" value={config.placeholdarrSettings?.DUMMY_FILE_PATH || ''} onChange={handleChange} placeholder="/data/dummy.mp4" style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                      </Box>
                      {/* ...repeat for all documented Placeholdarr options... */}
                      <Box display="flex" gap={2} alignItems="center" mb={2}>
                        <Typography style={{ color: '#fff' }}>Placeholder Strategy</Typography>
                        <input name="placeholdarrSettings.PLACEHOLDER_STRATEGY" value={config.placeholdarrSettings?.PLACEHOLDER_STRATEGY || ''} onChange={handleChange} placeholder="hardlink" style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                      </Box>
                      {/* ...repeat for all other Placeholdarr advanced options, matching backend... */}
                      <Box display="flex" gap={2} alignItems="center" mb={2}>
                        <Typography style={{ color: '#fff' }}>Extra Env</Typography>
                        <input name="placeholdarrSettings.extra_env" value={config.placeholdarrSettings?.extra_env || ''} onChange={handleChange} placeholder="{}" style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                      </Box>
                      <Box display="flex" gap={2} alignItems="center" mb={2}>
                        <Typography style={{ color: '#fff' }}>Extra Args</Typography>
                        <input name="placeholdarrSettings.extra_args" value={config.placeholdarrSettings?.extra_args || ''} onChange={handleChange} placeholder="" style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                      </Box>
                    </Box>
                  )}
                </Box>
              )}
              {/* Repeat similar advanced config UI for NZBGet, RDT-Client, Gaps, cli-debrid, ImageMaid, CineSync, Zurg, Decypharr, etc., matching backend-documented options */}
            </Box>
          )}
          {activeStep === 6 && (
            <Box>
              <Typography variant="h6" style={{ color: '#fff', marginBottom: 16 }}>Monitoring & Interface</Typography>
              <Box display="flex" gap={3} mb={3} justifyContent="center">
                {monitoringList.map((tool) => (
                  <Tooltip key={tool.key} title={tool.desc} placement="top">
                    <Box
                      onClick={() => setMonitoring((prev) => ({ ...prev, [tool.key]: !prev[tool.key] }))}
                      sx={{
                        cursor: 'pointer',
                        opacity: monitoring[tool.key] ? 1 : 0.4,
                        filter: monitoring[tool.key] ? 'none' : 'grayscale(100%)',
                        border: monitoring[tool.key] ? '2px solid #07938f' : '2px solid #444',
                        borderRadius: 2,
                        p: 1,
                        background: '#181818',
                        transition: 'all 0.2s',
                        position: 'relative',
                        boxShadow: monitoring[tool.key] ? '0 0 8px #07938f' : 'none',
                        '&:hover': { boxShadow: '0 0 16px #07938f' }
                      }}
                    >
                      <img src={tool.logo} alt={tool.name} style={{ width: 64, height: 64, display: 'block', margin: '0 auto' }} />
                      <Typography align="center" style={{ color: '#fff', fontSize: 14, marginTop: 4 }}>{tool.name}</Typography>
                      {!monitoring[tool.key] && (
                        <Box sx={{
                          position: 'absolute',
                          top: 0,
                          left: 0,
                          width: '100%',
                          height: '100%',
                          bgcolor: 'rgba(40,40,40,0.6)',
                          borderRadius: 2
                        }} />
                      )}
                    </Box>
                  </Tooltip>
                ))}
              </Box>
              {/* Sub-sections for enabled monitoring tools */}
              {monitoringList.filter((tool) => monitoring[tool.key]).map((tool) => (
                <Box key={tool.key} sx={{ background: '#232323', borderRadius: 2, p: 2, mb: 2, mt: 2, border: '2px solid #07938f' }}>
                  <Typography variant="subtitle1" style={{ color: '#fff', fontWeight: 600, marginBottom: 8 }}>{tool.name}</Typography>
                  {/* Overseerr fields (all variables, with info icons and tooltips) */}
                  {tool.key === 'overseerr' && (
                    <Box>
                      <Box display="grid" gridTemplateColumns="1fr" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Host/URL
                            <Tooltip title="The URL or IP address where Overseerr is accessible (e.g. http://overseerr:5055).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="overseerr_url" value={config.overseerrUrl || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrUrl: e.target.value }))} placeholder="http://overseerr:5055" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Port
                            <Tooltip title="The port Overseerr listens on (default: 5055).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="overseerr_port" value={config.overseerrPort || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrPort: e.target.value }))} placeholder="5055" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>SSL/TLS
                            <Tooltip title="Enable SSL/TLS for secure Overseerr access.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select name="overseerr_ssl" value={config.overseerrSsl || 'false'} onChange={e => setConfig(prev => ({ ...prev, overseerrSsl: e.target.value }))} style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}>
                            <option value="false">False</option>
                            <option value="true">True</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Base URL
                            <Tooltip title="Base URL for Overseerr if running behind a reverse proxy (e.g. /overseerr).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="overseerr_baseurl" value={config.overseerrBaseUrl || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrBaseUrl: e.target.value }))} placeholder="/overseerr" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>API Key
                            <Tooltip title="API key for Overseerr API access.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="overseerr_apikey" value={config.overseerrApiKey || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrApiKey: e.target.value }))} placeholder="API Key" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Username
                            <Tooltip title="Username for Overseerr web interface (if set).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="overseerr_username" value={config.overseerrUsername || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrUsername: e.target.value }))} placeholder="username (optional)" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Password
                            <Tooltip title="Password for Overseerr web interface (if set).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="overseerr_password" type="password" value={config.overseerrPassword || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrPassword: e.target.value }))} placeholder="password (optional)" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Default Language
                            <Tooltip title="Default language for Overseerr UI and notifications.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="overseerr_language" value={config.overseerrLanguage || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrLanguage: e.target.value }))} placeholder="en" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Log Level
                            <Tooltip title="Logging level for Overseerr (info, debug, warn, error).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="overseerr_loglevel" value={config.overseerrLogLevel || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrLogLevel: e.target.value }))} placeholder="info" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Notification Email
                            <Tooltip title="Email address for Overseerr notifications.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="overseerr_email" value={config.overseerrEmail || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrEmail: e.target.value }))} placeholder="user@email.com" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Request Limit
                            <Tooltip title="Maximum number of requests per user (if set).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="overseerr_requestlimit" value={config.overseerrRequestLimit || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrRequestLimit: e.target.value }))} placeholder="10" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Authentication Method
                            <Tooltip title="Authentication method for Overseerr (e.g. Plex, local, etc).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="overseerr_authmethod" value={config.overseerrAuthMethod || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrAuthMethod: e.target.value }))} placeholder="plex" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                    <Box width="100%" display="grid" gridTemplateColumns="repeat(auto-fit, minmax(320px, 1fr))" gap={0} style={{ marginTop: 0 }}>
                      </Box>
                        </Box>
                      </Box>
                    </Box>
                  )}
                  {/* Tautulli fields (expanded) */}
                  {tool.key === 'tautulli' && (
                    <Box display="flex" flexDirection="column" gap={2}>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Host/URL
                            <Tooltip title="The URL or IP address where Tautulli is accessible (e.g. http://tautulli:8181).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="tautulli_url" value={config.tautulliUrl || ''} onChange={e => setConfig(prev => ({ ...prev, tautulliUrl: e.target.value }))} placeholder="http://tautulli:8181" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Port
                            <Tooltip title="The port Tautulli listens on (default: 8181).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="tautulli_port" value={config.tautulliPort || ''} onChange={e => setConfig(prev => ({ ...prev, tautulliPort: e.target.value }))} placeholder="8181" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>PUID
                            <Tooltip title="User ID for running the Tautulli container (for Docker).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="tautulli_puid" value={config.tautulliPuid || ''} onChange={e => setConfig(prev => ({ ...prev, tautulliPuid: e.target.value }))} placeholder="1000" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>PGID
                            <Tooltip title="Group ID for running the Tautulli container (for Docker).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="tautulli_pgid" value={config.tautulliPgid || ''} onChange={e => setConfig(prev => ({ ...prev, tautulliPgid: e.target.value }))} placeholder="1000" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Timezone
                            <Tooltip title="Timezone for Tautulli (e.g. UTC, America/New_York).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="tautulli_tz" value={config.tautulliTz || ''} onChange={e => setConfig(prev => ({ ...prev, tautulliTz: e.target.value }))} placeholder="UTC" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>API Key
                            <Tooltip title="API key for Tautulli API access.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="tautulli_apikey" value={config.tautulliApiKey || ''} onChange={e => setConfig(prev => ({ ...prev, tautulliApiKey: e.target.value }))} placeholder="API Key" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Plex URL
                            <Tooltip title="The URL or IP address of your Plex Media Server.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="tautulli_plexurl" value={config.tautulliPlexUrl || ''} onChange={e => setConfig(prev => ({ ...prev, tautulliPlexUrl: e.target.value }))} placeholder="http://plex:32400" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Plex Token
                            <Tooltip title="Plex authentication token for Tautulli to access your server.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="tautulli_plextoken" value={config.tautulliPlexToken || ''} onChange={e => setConfig(prev => ({ ...prev, tautulliPlexToken: e.target.value }))} placeholder="Plex Token" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Log Level
                            <Tooltip title="Logging level for Tautulli (info, debug, warn, error).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="tautulli_loglevel" value={config.tautulliLogLevel || ''} onChange={e => setConfig(prev => ({ ...prev, tautulliLogLevel: e.target.value }))} placeholder="info" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                      </Box>
                    </Box>
                  )}
                  {/* Homepage fields */}
                  {tool.key === 'homepage' && (
                    <Box display="flex" flexDirection="column" gap={2}>
                      <Typography style={{ color: '#fff', background: '#232323', padding: 12, borderRadius: 4, marginBottom: 8 }}>
                        Homepage will automatically be configured.
                      </Typography>
                      {/* ...Homepage fields as above... */}
                    </Box>
                  )}
                </Box>
              ))}
            </Box>
          )}
          {activeStep === 7 && (
            <Box>
              <Typography variant="h6" style={{ color: '#fff' }}>Shared Configuration</Typography>
              <Box mb={2}>
                <Typography style={{ color: '#fff', marginBottom: 4 }}>Destination Directory</Typography>
                <Box display="flex" gap={2} alignItems="center">
                  <input
                    type="text"
                    name="destinationDirectory"
                    placeholder="/mnt/downloads or /home/user/Downloads"
                    value={config.destinationDirectory || ''}
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
                          setConfig((prev) => ({ ...prev, destinationDirectory: dirHandle.name }));
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
                <Typography style={{ color: '#aaa', fontSize: 13, marginTop: 8 }}>
                  This directory will be used as the destination for all download clients.
                </Typography>
              </Box>
              <input name="discordWebhook" placeholder="Discord Webhook URL" value={config.discordWebhook} onChange={handleChange} style={{width:'100%',margin:'8px 0',background:'#222',color:'#fff',border:'1px solid #444',borderRadius:4}} />
              <input name="traktApiKey" placeholder="Trakt API Key" value={config.traktApiKey} onChange={handleChange} style={{width:'100%',margin:'8px 0',background:'#222',color:'#fff',border:'1px solid #444',borderRadius:4}} />
              <select name="timezone" value={config.timezone} onChange={handleChange} style={{width:'100%',margin:'8px 0',background:'#222',color:'#fff',border:'1px solid #444',borderRadius:4}}>
                <option value="">Select Timezone</option>
                <option value="UTC">UTC</option>
                <option value="America/New_York">America/New_York</option>
                <option value="America/Chicago">America/Chicago</option>
                <option value="America/Denver">America/Denver</option>
                <option value="America/Los_Angeles">America/Los_Angeles</option>
                <option value="Europe/London">Europe/London</option>
                <option value="Europe/Berlin">Europe/Berlin</option>
                <option value="Europe/Paris">Europe/Paris</option>
                <option value="Europe/Moscow">Europe/Moscow</option>
                <option value="Asia/Tokyo">Asia/Tokyo</option>
                <option value="Asia/Shanghai">Asia/Shanghai</option>
                <option value="Asia/Kolkata">Asia/Kolkata</option>
                <option value="Australia/Sydney">Australia/Sydney</option>
                <option value="Pacific/Auckland">Pacific/Auckland</option>
              </select>
              <input name="userId" placeholder="User ID (default 1000)" value={config.userId} onChange={handleChange} style={{width:'100%',margin:'8px 0',background:'#222',color:'#fff',border:'1px solid #444',borderRadius:4}} />
              <input name="groupId" placeholder="Group ID (default 1000)" value={config.groupId} onChange={handleChange} style={{width:'100%',margin:'8px 0',background:'#222',color:'#fff',border:'1px solid #444',borderRadius:4}} />
            </Box>
          )}
          {activeStep === 8 && (
            <Box>
              <Typography variant="h6" style={{ color: '#fff' }}>Review</Typography>
              <pre style={{ color: '#fff', background: '#222', padding: 12, borderRadius: 4 }}>{JSON.stringify(config, null, 2)}</pre>
              <Button onClick={handleSave} variant="contained">Save Configuration</Button>
            </Box>
          )}
          {activeStep === 9 && (
            <Box>
              <Typography variant="h6" style={{ color: '#fff' }}>Deploy</Typography>
              <Button 
                onClick={async () => {
                  setShowProgress(true);
                  setProgress(0);
                  setProgressMessage('Adjusting configs...');
                  setTimeEstimate(10); // initial estimate in seconds
                  // Simulate progress
                  let percent = 0;
                  let interval = setInterval(() => {
                    percent += 10;
                    setProgress(percent);
                    setTimeEstimate((prev) => prev - 1);
                    if (percent >= 100) {
                      clearInterval(interval);
                      setProgressMessage('Deploying containers...');
                    }
                  }, 1000);
                  await handleDeploy();
                  setShowProgress(false);
                }}
                variant="contained"
                disabled={!config.storagePath}
              >
                Deploy Services
              </Button>
              {!config.storagePath && (
                <Typography style={{ color: '#ffb300', marginTop: 8 }}>
                  Please set a Storage Path before deploying.
                </Typography>
              )}
              {showProgress && (
                <Box mt={2}>
                  <Typography style={{ color: '#fff' }}>{progressMessage} {progress}% ({timeEstimate}s left)</Typography>
                  <Box sx={{ width: '100%', background: '#333', borderRadius: 4, mt: 1 }}>
                    <Box sx={{ width: `${progress}%`, background: '#07938f', height: 12, borderRadius: 4, transition: 'width 0.5s' }} />
                  </Box>
                </Box>
              )}
              <Typography style={{ color: '#fff' }}>{deployResult}</Typography>
            </Box>
          )}
        </Box>
        <Box display="flex" justifyContent="space-between">
          <Button disabled={activeStep === 0} onClick={handleBack} variant="outlined" style={{ color: '#fff', borderColor: '#fff' }}>Back</Button>
          <Button
            disabled={
              (activeStep === 2 && !config.storagePath) ||
              activeStep === steps.length - 1
            }
            onClick={() => {
              if (activeStep === 1 && !config.mediaServer) {
                setShowNoMediaServerDialog(true);
              } else {
                handleNext();
              }
            }}
            variant="outlined"
            style={{ color: '#fff', borderColor: '#fff' }}
          >
            Next
          </Button>
      {/* Confirmation dialog for no media server selected */}
      {showNoMediaServerDialog && (
        <Box position="fixed" top={0} left={0} width="100vw" height="100vh" zIndex={2000} display="flex" alignItems="center" justifyContent="center" style={{ background: 'rgba(0,0,0,0.7)' }}>
          <Box bgcolor="#232323" p={4} borderRadius={4} boxShadow={4} minWidth={320}>
            <Typography style={{ color: '#fff', marginBottom: 16 }}>
              You have not selected a media server. Are you sure you want to continue?
            </Typography>
            <Box display="flex" justifyContent="flex-end" gap={2}>
              <Button onClick={() => setShowNoMediaServerDialog(false)} variant="outlined" style={{ color: '#fff', borderColor: '#fff' }}>Cancel</Button>
              <Button onClick={() => { setShowNoMediaServerDialog(false); handleNext(); }} variant="contained" color="primary">Continue</Button>
            </Box>
          </Box>
        </Box>
      )}
      {/* Confirmation dialog for no media server selected */}
      {showNoMediaServerDialog && (
        <Box position="fixed" top={0} left={0} width="100vw" height="100vh" zIndex={2000} display="flex" alignItems="center" justifyContent="center" style={{ background: 'rgba(0,0,0,0.7)' }}>
          <Box bgcolor="#232323" p={4} borderRadius={4} boxShadow={4} minWidth={320}>
            <Typography style={{ color: '#fff', marginBottom: 16 }}>
              You have not selected a media server. Are you sure you want to continue?
            </Typography>
            <Box display="flex" justifyContent="flex-end" gap={2}>
              <Button onClick={() => setShowNoMediaServerDialog(false)} variant="outlined" style={{ color: '#fff', borderColor: '#fff' }}>Cancel</Button>
              <Button onClick={() => { setShowNoMediaServerDialog(false); setActiveStep((prev) => prev + 1); }} variant="contained" color="primary">Continue</Button>
            </Box>
          </Box>
        </Box>
      )}
        </Box>
      </Box>
      </Container>
      </div>
    </>
  );
}

export default App;

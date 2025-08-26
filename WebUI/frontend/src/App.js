import React, { useEffect } from 'react';
import MediaServerStep from './MediaServerStep';
import StorageConfigStep from './StorageConfigStep';
import ExternalAPIStep from './ExternalAPIStep';
import AdditionalServicesStep from './AdditionalServicesStep';
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
import decypharrLogo from './assets/service-logos/decypharr.png';

const steps = [
  'Welcome',
  'Media Server',
  'Storage Config',
  'External APIs',
  'Additional Services',
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
    // { key: 'zurg', name: 'Zurg', desc: 'NZBGet/Usenet automation tool', logo: zurgLogo },
    { key: 'decypharr', name: 'Decypharr', desc: 'Decryption and post-processing tool', logo: decypharrLogo }
  ];
  const [downloadTools, setDownloadTools] = React.useState({
    nzbget: true,
    rdtclient: true,
    gaps: true,
    // zurg: true,
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
      <style>{`
        .MuiButton-root, .MuiButton-outlined, .MuiButton-contained {
          box-shadow: none !important;
          -webkit-box-shadow: none !important;
          outline: none !important;
        }
        .MuiButton-root:focus, .MuiButton-root:focus-visible, .Mui-focusVisible {
          box-shadow: none !important;
          outline: none !important;
        }
      `}</style>
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
        <Container style={{ width: '100%', background: 'rgba(17,17,17,0.92)', borderRadius: 12, boxShadow: 'none', padding: 0, minHeight: '90vh', display: 'flex', flexDirection: 'column', justifyContent: 'flex-start' }}>
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
          </Box>
          <Box sx={{ flex: 1, minHeight: 400, my: 4, display: 'flex', flexDirection: 'column', justifyContent: 'flex-start' }}>
            {activeStep === 1 && (
              <MediaServerStep config={config} setConfig={setConfig} coreServers={coreServers} />
            )}
            {activeStep === 2 && (
              <StorageConfigStep
                config={config}
                setConfig={setConfig}
                nextButton={
                  <Button
                    disableRipple
                    disableElevation
                    disabled={!config.storagePath}
                    onClick={handleNext}
                    variant="outlined"
                    sx={{ color: '#fff', borderColor: '#fff', boxShadow: 'none', '&:hover': { boxShadow: 'none' }, '&:focus': { boxShadow: 'none', outline: 'none' }, '&.Mui-focusVisible': { boxShadow: 'none', outline: 'none' } }}
                  >
                    Next
                  </Button>
                }
              />
            )}
            {activeStep === 3 && (
              <ExternalAPIStep config={config} setConfig={setConfig} />
            )}
            {activeStep === 4 && (
              <AdditionalServicesStep
                contentEnhancementList={contentEnhancementList}
                contentEnhancement={contentEnhancement}
                setContentEnhancement={setContentEnhancement}
                showKometaAdvanced={showKometaAdvanced}
                setShowKometaAdvanced={setShowKometaAdvanced}
                showPosterizarrAdvanced={showPosterizarrAdvanced}
                setShowPosterizarrAdvanced={setShowPosterizarrAdvanced}
                showPlaceholdarrAdvanced={showPlaceholdarrAdvanced}
                setShowPlaceholdarrAdvanced={setShowPlaceholdarrAdvanced}
                config={config}
                setConfig={setConfig}
                handleChange={handleChange}
              />
            )}
            {activeStep === 5 && (
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
          <Box display="flex" justifyContent="space-between" sx={{ mt: 'auto', mb: 2, px: 2, py: 1, borderRadius: 2, background: 'transparent', border: 'none' }}>
            {activeStep === 0 ? (
              // Hide Back button on Welcome screen
              <div />
            ) : (
              <Button disabled={activeStep === 0} onClick={handleBack} variant="outlined" disableRipple disableElevation sx={{ color: '#fff', borderColor: '#fff', boxShadow: 'none', '&:hover': { boxShadow: 'none' }, '&:focus': { boxShadow: 'none', outline: 'none' }, '&.Mui-focusVisible': { boxShadow: 'none', outline: 'none' } }}>Back</Button>
            )}

            <Button
              disableRipple
              disableElevation
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
              sx={{ color: '#fff', borderColor: '#fff', boxShadow: 'none', '&:hover': { boxShadow: 'none' }, '&:focus': { boxShadow: 'none', outline: 'none' }, '&.Mui-focusVisible': { boxShadow: 'none', outline: 'none' } }}
            >
              Next
            </Button>
          </Box>
        </Container>
      </div>
    </>
  );
  }
  
  export default App;

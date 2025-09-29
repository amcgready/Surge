// Utility to read Pangolin setup token from backend
export async function getPangolinSetupToken() {
  try {
    const resp = await fetch('/api/env');
    if (!resp.ok) return '';
    const env = await resp.json();
    return env.PANGOLIN_SETUP_TOKEN || '';
  } catch (e) {
    return '';
  }
}

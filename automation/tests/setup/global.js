import { ensureArtifactDir } from '../helpers/artifacts.js';
import { shutdownDriver } from '../helpers/session.js';

before(async () => {
  ensureArtifactDir();
});

after(async () => {
  await shutdownDriver();
});

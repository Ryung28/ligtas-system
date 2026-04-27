const fs = require('node:fs')
const path = require('node:path')

const repoRoot = path.resolve(__dirname, '..', '..')
const sourceDir = path.join(repoRoot, 'web', 'public', 'sounds')
const mobileAssetsDir = path.join(repoRoot, 'mobile', 'assets', 'sounds')
const androidRawDir = path.join(
  repoRoot,
  'mobile',
  'android',
  'app',
  'src',
  'main',
  'res',
  'raw',
)

const REQUIRED_FILES = ['notification.mp3', 'critical_alarm.mp3']

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true })
}

function assertFileExists(filePath) {
  if (!fs.existsSync(filePath)) {
    throw new Error(`Required sound file not found: ${filePath}`)
  }
}

function copyFile(sourcePath, targetPath) {
  fs.copyFileSync(sourcePath, targetPath)
  const size = fs.statSync(targetPath).size
  console.log(`Synced ${path.basename(sourcePath)} -> ${targetPath} (${size} bytes)`)
}

function main() {
  if (!fs.existsSync(sourceDir)) {
    throw new Error(`Source sounds directory missing: ${sourceDir}`)
  }

  ensureDir(mobileAssetsDir)
  ensureDir(androidRawDir)

  for (const fileName of REQUIRED_FILES) {
    const source = path.join(sourceDir, fileName)
    assertFileExists(source)

    copyFile(source, path.join(mobileAssetsDir, fileName))
    copyFile(source, path.join(androidRawDir, fileName))
  }

  console.log('Sound sync complete.')
}

try {
  main()
} catch (error) {
  console.error('Sound sync failed.')
  console.error(error instanceof Error ? error.message : error)
  process.exit(1)
}

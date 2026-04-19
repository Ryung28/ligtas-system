/** @type {import('next').NextConfig} */
const nextConfig = {
  typescript: {
    ignoreBuildErrors: true, 
  },
  eslint: {
    ignoreDuringBuilds: true,
  },
  experimental: {
    serverActions: {
      bodySizeLimit: '10mb',
    },
  },
  webpack: (config, { dev, isServer }) => {
    if (dev && !isServer) {
      config.watchOptions = {
        poll: 2000,
        aggregateTimeout: 3000,
        ignored: /[\\/]node_modules[\\/]|[\\/]\.next[\\/]|System Volume Information|WindowsApps|\$RECYCLE\.BIN|Config\.Msi|Recovery/i
      }
    }
    return config
  },
};

module.exports = nextConfig;

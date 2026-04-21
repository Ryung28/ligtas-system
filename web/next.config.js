/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'knarlvwnuvedyfvvaota.supabase.co',
        port: '',
        pathname: '/storage/v1/object/public/**',
      },
    ],
  },
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
        aggregateTimeout: 5000,
        ignored: [
          '**/node_modules/**',
          '**/.next/**',
          '**/System Volume Information/**',
          '**/WindowsApps/**',
          '**/\$RECYCLE.BIN/**',
          '**/Config.Msi/**',
          '**/Recovery/**'
        ]
      }
    }
    return config
  },
};

module.exports = nextConfig;

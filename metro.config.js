const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

// Handle .wasm files from expo-sqlite
config.resolver.assetExts = [
  ...config.resolver.assetExts.filter((ext) => ext !== 'wasm'),
  'wasm',
];

module.exports = config;

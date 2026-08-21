import React from 'react';
import { View, Text, StyleSheet, Platform } from 'react-native';
import Svg, { Rect, Path } from 'react-native-svg';
import { useTheme } from '../hooks/useTheme';

interface LogoIconProps {
  size?: number;
  color?: string;
}

export function LogoIcon({ size = 52, color }: LogoIconProps) {
  const { theme } = useTheme();
  const fill = color ?? '#FFFFFF';

  return (
    <Svg width={size} height={size} viewBox="0 0 200 200" fill="none">
      <Rect x="30" y="96" width="34" height="70" rx="8" fill={fill} fillOpacity={0.92} />
      <Rect x="83" y="66" width="34" height="100" rx="8" fill={fill} fillOpacity={0.92} />
      <Rect x="136" y="36" width="34" height="130" rx="8" fill={fill} fillOpacity={0.92} />
      <Path
        d="M 128 58 L 153 30 L 178 58"
        fill="none"
        stroke={fill}
        strokeWidth="9"
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeOpacity={0.92}
      />
    </Svg>
  );
}

export function AppLogo() {
  const { theme } = useTheme();
  const isDark = theme === 'dark';

  return (
    <View style={styles.wrap}>
      <LogoIcon size={72} />
      <Text style={[styles.wordmark, { color: '#FFFFFF' }]}>
        <Text style={styles.light}>Finanz</Text>App
      </Text>
      <Text style={[styles.tagline, { color: 'rgba(255,255,255,0.6)' }]}>
        Le tue finanze, a colpo d'occhio
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: {
    alignItems: 'center',
    paddingVertical: 8,
  },
  wordmark: {
    fontSize: 28,
    fontWeight: '700',
    letterSpacing: -0.5,
    fontFamily: Platform.select({ ios: '-apple-system', default: 'System' }) as string,
    marginTop: 10,
  },
  light: {
    fontWeight: '600',
    opacity: 0.88,
  },
  tagline: {
    fontSize: 12,
    fontWeight: '600',
    letterSpacing: 0.2,
    marginTop: 4,
    fontFamily: Platform.select({ ios: '-apple-system', default: 'System' }) as string,
  },
});

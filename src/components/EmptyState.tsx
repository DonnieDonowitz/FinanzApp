import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { useTheme } from '../hooks/useTheme';
import Svg, { Path, Circle, Line } from 'react-native-svg';
import { GlassView } from './GlassView';

interface EmptyStateProps {
  message: string;
  subMessage?: string;
}

function EmptyIcon({ color }: { color: string }) {
  return (
    <Svg width={36} height={36} viewBox="0 0 24 24" fill="none">
      <Path
        d="M7 3h6l5 5v13a1 1 0 01-1 1H7a1 1 0 01-1-1V4a1 1 0 011-1z"
        stroke={color}
        strokeWidth={1.4}
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeOpacity={0.4}
      />
      <Path
        d="M13 3v4a1 1 0 001 1h4"
        stroke={color}
        strokeWidth={1.4}
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeOpacity={0.25}
      />
      <Circle cx="10" cy="11" r="3" stroke={color} strokeWidth={1.4} strokeOpacity={0.5} />
      <Line x1="12" y1="13" x2="14" y2="15" stroke={color} strokeWidth={1.4} strokeLinecap="round" strokeOpacity={0.5} />
    </Svg>
  );
}

export function EmptyState({ message, subMessage }: EmptyStateProps) {
  const { colors } = useTheme();
  const iconColor = colors.textTertiary;

  return (
    <GlassView intensity="regular" borderRadius={20} style={styles.container}>
      <View style={[styles.iconWrap, { backgroundColor: colors.surface }]}>
        <EmptyIcon color={iconColor} />
      </View>
      <Text style={[styles.message, { color: colors.glassTextSecondary }]}>
        {message}
      </Text>
      {subMessage ? (
        <Text style={[styles.subMessage, { color: colors.glassTextTertiary }]}>
          {subMessage}
        </Text>
      ) : null}
    </GlassView>
  );
}

const styles = StyleSheet.create({
  container: {
    margin: 16,
    paddingVertical: 48,
    paddingHorizontal: 24,
    alignItems: 'center',
  },
  iconWrap: {
    width: 64,
    height: 64,
    borderRadius: 18,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 14,
  },
  message: {
    fontSize: 15,
    fontWeight: '600',
    fontFamily: '-apple-system',
    textAlign: 'center',
    lineHeight: 22,
    marginBottom: 4,
  },
  subMessage: {
    fontSize: 13,
    fontWeight: '500',
    fontFamily: '-apple-system',
    textAlign: 'center',
    lineHeight: 18,
  },
});

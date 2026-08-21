import React, { ReactNode } from 'react';
import { View, Text, StyleSheet, ViewStyle } from 'react-native';
import { useTheme } from '../hooks/useTheme';
import { GlassView } from './GlassView';

interface SectionCardProps {
  title?: string;
  subtitle?: string;
  children: ReactNode;
  style?: ViewStyle;
}

export function SectionCard({ title, subtitle, children, style }: SectionCardProps) {
  const { colors } = useTheme();

  return (
    <GlassView
      intensity="regular"
      style={style ? [styles.container, style] : styles.container}
      borderRadius={20}
    >
      <View style={styles.content}>
        {title && (
          <View style={[styles.header, { borderBottomColor: colors.divider }]}>
            <Text style={[styles.title, { color: colors.glassText }]}>{title}</Text>
            {subtitle && (
              <Text style={[styles.subtitle, { color: colors.glassTextSecondary }]}>{subtitle}</Text>
            )}
          </View>
        )}
        <View style={styles.contentInner}>{children}</View>
      </View>
    </GlassView>
  );
}

const styles = StyleSheet.create({
  container: {
    marginHorizontal: 16,
    marginBottom: 12,
  },
  content: {
    paddingHorizontal: 18,
    paddingTop: 16,
    paddingBottom: 12,
  },
  header: {
    marginBottom: 12,
    paddingBottom: 12,
    borderBottomWidth: 0.5,
  },
  title: {
    fontSize: 16,
    fontWeight: '700',
    fontFamily: '-apple-system',
    letterSpacing: -0.2,
  },
  subtitle: {
    fontSize: 12,
    fontWeight: '500',
    fontFamily: '-apple-system',
    marginTop: 2,
  },
  contentInner: {
    paddingTop: 0,
  },
});

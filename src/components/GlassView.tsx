import React, { ReactNode } from 'react';
import { View, StyleSheet, ViewStyle, Platform } from 'react-native';
import { BlurView } from 'expo-blur';
import { LinearGradient } from 'expo-linear-gradient';
import { useTheme } from '../hooks/useTheme';

export interface GlassViewProps {
  children: ReactNode;
  style?: ViewStyle | ViewStyle[];
  intensity?: 'regular' | 'strong';
  borderRadius?: number;
  borderWidth?: number;
  padding?: number;
  paddingHorizontal?: number;
  paddingVertical?: number;
  noHighlight?: boolean;
}

export function GlassView({
  children,
  style,
  intensity = 'regular',
  borderRadius = 28,
  borderWidth = 1,
  padding: paddingProp,
  paddingHorizontal: padH,
  paddingVertical: padV,
  noHighlight = false,
}: GlassViewProps) {
  const { colors } = useTheme();

  const blurIntensity = 24;
  const bgColor = intensity === 'strong' ? colors.glassStrong : colors.glass;
  const borderColor = intensity === 'strong' ? colors.glassStrongBorder : colors.glassBorder;

  const explicitPadding: ViewStyle = {};
  if (paddingProp !== undefined) explicitPadding.padding = paddingProp;
  if (padH !== undefined) explicitPadding.paddingHorizontal = padH;
  if (padV !== undefined) explicitPadding.paddingVertical = padV;

  const containerStyle: ViewStyle = {
    backgroundColor: bgColor,
    borderColor,
    borderWidth,
    borderRadius,
    shadowColor: colors.shadow,
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.45,
    shadowRadius: 30,
    elevation: 6,
  };

  const gradientColors: [string, string] = [
    colors.glassHighlight,
    'transparent',
  ];

  if (Platform.OS === 'web') {
    return (
      <View
        style={[
          styles.container,
          containerStyle,
          style,
          explicitPadding,
        ]}
      >
        {!noHighlight && (
          <LinearGradient
            colors={gradientColors}
            start={{ x: 0, y: 1 }}
            end={{ x: 1, y: 0 }}
            locations={[0, 0.4]}
            style={[StyleSheet.absoluteFill, { borderRadius }]}
            pointerEvents="none"
          />
        )}
        {children}
      </View>
    );
  }

  const styleArr = Array.isArray(style) ? style : [style];

  return (
    <BlurView
      intensity={blurIntensity}
      tint="dark"
      style={[styles.container, containerStyle, ...styleArr, explicitPadding]}

    >
      {!noHighlight && (
        <LinearGradient
          colors={gradientColors}
          start={{ x: 0, y: 1 }}
          end={{ x: 1, y: 0 }}
          locations={[0, 0.4]}
          style={[StyleSheet.absoluteFill, { borderRadius }]}
          pointerEvents="none"
        />
      )}
      {children}
    </BlurView>
  );
}

const styles = StyleSheet.create({
  container: {
    overflow: 'hidden',
  },
});

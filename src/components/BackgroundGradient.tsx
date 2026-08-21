import { StyleSheet } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { useTheme } from '../hooks/useTheme';

export function BackgroundGradient() {
  const { theme } = useTheme();
  const isDark = theme === 'dark';

  if (isDark) {
    return (
      <>
        <LinearGradient
          colors={['#0A0C14', '#0D0F1A', '#08090F']}
          start={{ x: 0.37, y: 0 }}
          end={{ x: 0.63, y: 1 }}
          style={StyleSheet.absoluteFill}
          pointerEvents="none"
        />
        <LinearGradient
          colors={['rgba(255,122,122,0.35)', 'rgba(255,122,122,0)']}
          start={{ x: 0.22, y: 0.15 }}
          end={{ x: 0.5, y: 0.43 }}
          style={StyleSheet.absoluteFill}
          pointerEvents="none"
        />
        <LinearGradient
          colors={['rgba(178,157,255,0.32)', 'rgba(178,157,255,0)']}
          start={{ x: 0.85, y: 0.10 }}
          end={{ x: 0.5, y: 0.45 }}
          style={StyleSheet.absoluteFill}
          pointerEvents="none"
        />
        <LinearGradient
          colors={['rgba(47,232,176,0.30)', 'rgba(47,232,176,0)']}
          start={{ x: 0.12, y: 0.80 }}
          end={{ x: 0.5, y: 0.5 }}
          style={StyleSheet.absoluteFill}
          pointerEvents="none"
        />
        <LinearGradient
          colors={['rgba(90,130,255,0.32)', 'rgba(90,130,255,0)']}
          start={{ x: 0.90, y: 0.88 }}
          end={{ x: 0.5, y: 0.5 }}
          style={StyleSheet.absoluteFill}
          pointerEvents="none"
        />
      </>
    );
  }

  return (
    <>
      <LinearGradient
        colors={['#5E52D6', '#3D74DD', '#1B9FC4']}
        start={{ x: 0.37, y: 0 }}
        end={{ x: 0.63, y: 1 }}
        style={StyleSheet.absoluteFill}
        pointerEvents="none"
      />
      <LinearGradient
        colors={['rgba(255,159,107,0.90)', 'rgba(255,159,107,0)']}
        start={{ x: 0.22, y: 0.18 }}
        end={{ x: 0.5, y: 0.43 }}
        style={StyleSheet.absoluteFill}
        pointerEvents="none"
      />
      <LinearGradient
        colors={['rgba(167,139,250,0.85)', 'rgba(167,139,250,0)']}
        start={{ x: 0.82, y: 0.12 }}
        end={{ x: 0.5, y: 0.47 }}
        style={StyleSheet.absoluteFill}
        pointerEvents="none"
      />
      <LinearGradient
        colors={['rgba(31,216,164,0.85)', 'rgba(31,216,164,0)']}
        start={{ x: 0.15, y: 0.78 }}
        end={{ x: 0.5, y: 0.5 }}
        style={StyleSheet.absoluteFill}
        pointerEvents="none"
      />
      <LinearGradient
        colors={['rgba(76,111,255,0.85)', 'rgba(76,111,255,0)']}
        start={{ x: 0.88, y: 0.85 }}
        end={{ x: 0.5, y: 0.5 }}
        style={StyleSheet.absoluteFill}
        pointerEvents="none"
      />
    </>);
}

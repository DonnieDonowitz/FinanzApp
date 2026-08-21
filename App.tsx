import React from 'react';
import { NavigationContainer, DarkTheme as NavDarkTheme, DefaultTheme as NavDefaultTheme } from '@react-navigation/native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import { AppProvider } from './src/context/AppContext';
import { AppNavigator } from './src/navigation/AppNavigator';
import { ActivityIndicator, View } from 'react-native';
import { useAppContext } from './src/context/AppContext';
import { getColors } from './src/utils/colors';
import { BackgroundGradient } from './src/components/BackgroundGradient';

function AppContent() {
  const { state } = useAppContext();
  const colors = getColors(state.settings.theme);
  const isDark = state.settings.theme === 'dark';

  const navTheme = isDark
    ? {
        ...NavDarkTheme,
        colors: {
          ...NavDarkTheme.colors,
          background: 'transparent',
          card: colors.surface,
          text: colors.text,
          border: colors.divider,
          primary: colors.primary,
        },
      }
    : {
        ...NavDefaultTheme,
        colors: {
          ...NavDefaultTheme.colors,
          background: 'transparent',
          card: colors.surface,
          text: colors.text,
          border: colors.divider,
          primary: colors.primary,
        },
      };

  if (state.isLoading) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
        <BackgroundGradient />
        <ActivityIndicator size="large" color={colors.primary} />
      </View>
    );
  }

  return (
    <View style={{ flex: 1 }}>
      <BackgroundGradient />
      <StatusBar style={isDark ? 'light' : 'dark'} />
      <NavigationContainer theme={navTheme}>
        <AppNavigator />
      </NavigationContainer>
    </View>
  );
}

export default function App() {
  return (
    <SafeAreaProvider>
      <AppProvider>
        <AppContent />
      </AppProvider>
    </SafeAreaProvider>
  );
}

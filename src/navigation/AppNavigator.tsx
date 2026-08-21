import React, { useRef, useMemo, useCallback } from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { Platform, View, Text, TouchableOpacity, StyleSheet, PanResponder, Dimensions } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useTheme } from '../hooks/useTheme';
import { BlurView } from 'expo-blur';

import { HomeScreen } from '../screens/HomeScreen';
import { TransactionsScreen } from '../screens/TransactionsScreen';
import { AddTransactionScreen } from '../screens/AddTransactionScreen';
import { StatisticsScreen } from '../screens/StatisticsScreen';
import { AnnualSummaryScreen } from '../screens/AnnualSummaryScreen';
import { SettingsScreen } from '../screens/SettingsScreen';
import { ManageCategoriesScreen } from '../screens/ManageCategoriesScreen';
import { RecurringScreen } from '../screens/RecurringScreen';
import { AddRecurringScreen } from '../screens/AddRecurringScreen';

const SWIPE_THRESHOLD = 50;
const TAB_ROUTES = ['Home', 'Transazioni', 'Ricorrenti', 'Impostazioni'];

const TAB_EMOJIS: Record<string, string> = {
  Home: '📊',
  Transazioni: '💳',
  Ricorrenti: '🔄',
  Impostazioni: '⚙️',
};

const TAB_LABELS: Record<string, string> = {
  Home: 'Home',
  Transazioni: 'Movimenti',
  Ricorrenti: 'Ricorrenti',
  Impostazioni: 'Altro',
};

const Tab = createBottomTabNavigator();
const HS = createNativeStackNavigator();
const TS = createNativeStackNavigator();
const RS = createNativeStackNavigator();
const IS = createNativeStackNavigator();

function HomeStackS() {
  return (
    <HS.Navigator screenOptions={{ headerShown: false }}>
      <HS.Screen name="HomeMain" component={HomeScreen} />
      <HS.Screen name="AddTransaction" component={AddTransactionScreen} />
    </HS.Navigator>
  );
}

function TransStackS() {
  return (
    <TS.Navigator screenOptions={{ headerShown: false }}>
      <TS.Screen name="TransactionsMain" component={TransactionsScreen} />
      <TS.Screen name="AddTransaction" component={AddTransactionScreen} />
      <TS.Screen name="EditTransaction" component={AddTransactionScreen} />
    </TS.Navigator>
  );
}

function RecurringStackS() {
  return (
    <RS.Navigator screenOptions={{ headerShown: false }}>
      <RS.Screen name="RecurringMain" component={RecurringScreen} />
      <RS.Screen name="AddRecurring" component={AddRecurringScreen} />
      <RS.Screen name="EditRecurring" component={AddRecurringScreen} />
    </RS.Navigator>
  );
}

function SettingsStackS() {
  return (
    <IS.Navigator screenOptions={{ headerShown: false }}>
      <IS.Screen name="SettingsMain" component={SettingsScreen} />
      <IS.Screen name="ManageCategories" component={ManageCategoriesScreen} />
      <IS.Screen name="Statistics" component={StatisticsScreen} />
      <IS.Screen name="AnnualSummary" component={AnnualSummaryScreen} />
    </IS.Navigator>
  );
}

function CustomTabBar({ state, descriptors, navigation, insets }: any) {
  const { colors, theme } = useTheme();
  const isDark = theme === 'dark';

  return (
    <BlurView
      intensity={isDark ? 36 : 24}
      tint={isDark ? 'dark' : 'light'}
      style={[
        styles.tabBar,
        {
          backgroundColor: isDark ? 'rgba(255,255,255,0.07)' : 'rgba(255,255,255,0.18)',
          borderColor: isDark ? 'rgba(255,255,255,0.14)' : 'rgba(255,255,255,0.40)',
          marginBottom: Math.max(insets.bottom, 8) + 8,
          shadowColor: '#000',
        },
      ]}
    >
      <View style={styles.tabBarContent}>
        {state.routes.map((route: any, index: number) => {
          const focused = index === state.index;
          const { options } = descriptors[route.key];
          const label = options.tabBarLabel ?? route.name;

          return (
            <TouchableOpacity
              key={route.key}
              style={styles.tabItem}
              onPress={() => navigation.navigate(route.name)}
              onLongPress={() => navigation.emit({ type: 'tabLongPress', target: route.key })}
              activeOpacity={0.6}
            >
              <View style={[styles.iconContainer, focused && styles.iconContainerActive]}>
                <Text style={[styles.emoji, focused && styles.emojiActive]}>
                  {TAB_EMOJIS[route.name] || '📌'}
                </Text>
              </View>
              <Text style={[styles.label, { color: focused ? colors.tabActive : colors.tabInactive }]}>
                {label}
              </Text>
            </TouchableOpacity>
          );
        })}
      </View>
    </BlurView>
  );
}

const styles = StyleSheet.create({
  tabBar: {
    position: 'absolute',
    bottom: 0,
    left: 16,
    right: 16,
    borderRadius: 32,
    borderWidth: 1,
    shadowOffset: { width: 0, height: 12 },
    shadowOpacity: 0.28,
    shadowRadius: 32,
    elevation: 10,
    overflow: 'hidden',
  },
  tabBarContent: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'center',
    paddingTop: 6,
    paddingBottom: 8,
    paddingHorizontal: 8,
    height: 66,
  },
  tabItem: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: 48,
  },
  iconContainer: {
    width: 40,
    height: 34,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 18,
    marginBottom: 2,
  },
  iconContainerActive: {
    backgroundColor: 'rgba(255,255,255,0.92)',
  },
  emoji: {
    fontSize: 19,
    opacity: 0.6,
  },
  emojiActive: {
    opacity: 1,
  },
  label: {
    fontSize: 10,
    fontWeight: '600',
    fontFamily: '-apple-system',
    marginTop: 1,
    letterSpacing: 0.1,
  },
});

export function AppNavigator() {
  const { colors } = useTheme();
  const insets = useSafeAreaInsets();
  const navRef = useRef<any>(null);

  const panResponder = useMemo(() => PanResponder.create({
    onStartShouldSetPanResponder: () => false,
    onMoveShouldSetPanResponder: (e, g) => {
      const screenH = Dimensions.get('window').height;
      const touchY = e.nativeEvent.pageY;
      const isNearBottom = touchY > screenH - 100 - insets.bottom;
      return isNearBottom && Math.abs(g.dx) > Math.abs(g.dy) && Math.abs(g.dx) > 15;
    },
    onPanResponderRelease: (_, g) => {
      const nav = navRef.current;
      if (!nav) return;
      const state = nav.getState();
      const currentIndex = state?.index ?? 0;
      if (g.dx < -SWIPE_THRESHOLD && currentIndex < TAB_ROUTES.length - 1) {
        nav.navigate(TAB_ROUTES[currentIndex + 1]);
      } else if (g.dx > SWIPE_THRESHOLD && currentIndex > 0) {
        nav.navigate(TAB_ROUTES[currentIndex - 1]);
      }
    },
  }), [insets.bottom]);

  const tabBar = useCallback(
    (props: any) => {
      navRef.current = props.navigation;
      return <CustomTabBar {...props} insets={insets} />;
    },
    [insets]
  );

  return (
    <View style={{ flex: 1 }} {...panResponder.panHandlers}>
      <Tab.Navigator
        screenOptions={{
          headerShown: false,
          tabBarStyle: { display: 'none' },
          tabBarActiveTintColor: colors.tabActive,
          tabBarInactiveTintColor: colors.tabInactive,
          tabBarShowLabel: true,
          tabBarLabelStyle: styles.label,
          tabBarHideOnKeyboard: true,
        }}
        tabBar={tabBar}
      >
        <Tab.Screen name="Home" component={HomeStackS} options={{ tabBarLabel: 'Home' }} />
        <Tab.Screen name="Transazioni" component={TransStackS} options={{ tabBarLabel: 'Movimenti' }} />
        <Tab.Screen name="Ricorrenti" component={RecurringStackS} options={{ tabBarLabel: 'Ricorrenti' }} />
        <Tab.Screen name="Impostazioni" component={SettingsStackS} options={{ tabBarLabel: 'Altro' }} />
      </Tab.Navigator>
    </View>
  );
}

import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { useTheme } from '../hooks/useTheme';
import { useNavigation } from '@react-navigation/native';
import Svg, { Path } from 'react-native-svg';
import { GlassView } from './GlassView';

export function QuickAddBar() {
  const { colors } = useTheme();
  const navigation = useNavigation<any>();

  return (
    <View style={styles.container}>
      <GlassView intensity="strong" style={styles.buttonWrapper} borderRadius={18}>
        <TouchableOpacity
          style={styles.button}
          activeOpacity={0.6}
          onPress={() => navigation.navigate('AddTransaction', { type: 'income' })}
        >
          <View style={[styles.iconCircle, { backgroundColor: colors.income + '18' }]}>
            <Svg width={15} height={15} viewBox="0 0 24 24" fill="none">
              <Path d="M12 5v14M5 13l7 7 7-7" stroke={colors.income} strokeWidth={2.5} strokeLinecap="round" strokeLinejoin="round" />
            </Svg>
          </View>
          <Text style={[styles.buttonLabel, { color: colors.income }]}>Entrata</Text>
        </TouchableOpacity>
      </GlassView>

      <GlassView intensity="strong" style={styles.buttonWrapper} borderRadius={18}>
        <TouchableOpacity
          style={styles.button}
          activeOpacity={0.6}
          onPress={() => navigation.navigate('AddTransaction', { type: 'expense' })}
        >
          <View style={[styles.iconCircle, { backgroundColor: colors.expense + '18' }]}>
            <Svg width={15} height={15} viewBox="0 0 24 24" fill="none">
              <Path d="M12 19V5M5 11l7-7 7 7" stroke={colors.expense} strokeWidth={2.5} strokeLinecap="round" strokeLinejoin="round" />
            </Svg>
          </View>
          <Text style={[styles.buttonLabel, { color: colors.expense }]}>Uscita</Text>
        </TouchableOpacity>
      </GlassView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    paddingHorizontal: 16,
    paddingVertical: 6,
    gap: 10,
  },
  buttonWrapper: {
    flex: 1,
  },
  button: {
    flex: 1,
    paddingVertical: 14,
    borderRadius: 18,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
  },
  iconCircle: {
    width: 28,
    height: 28,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
  },
  buttonLabel: {
    fontSize: 14,
    fontWeight: '700',
    fontFamily: '-apple-system',
    letterSpacing: -0.1,
  },
});

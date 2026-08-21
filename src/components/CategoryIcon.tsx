import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { categoryIcon } from '../utils/constants';

interface Props {
  name: string;
  size?: number;
  color?: string;
  icon?: string;
}

export function CategoryIcon({ name, size = 24, color = '#666', icon }: Props) {
  const emoji = (icon && icon.trim().length > 0) ? icon.trim() : categoryIcon(name);

  return (
    <View style={[styles.wrap, { width: size, height: size, borderRadius: size * 0.38 }]}>
      <Text style={[styles.emoji, { fontSize: size * 0.55 }]}>{emoji}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  circle: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  emoji: {
    textAlign: 'center',
  },
  initial: {
    textAlign: 'center',
    fontFamily: '-apple-system',
  },
});

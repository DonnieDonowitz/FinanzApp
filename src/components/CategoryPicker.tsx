import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet, ScrollView } from 'react-native';
import { Category } from '../context/types';
import { useTheme } from '../hooks/useTheme';
import { CategoryIcon } from './CategoryIcon';

interface CategoryPickerProps {
  categories: Category[];
  selectedId: number | null;
  onSelect: (category: Category) => void;
}

export function CategoryPicker({ categories, selectedId, onSelect }: CategoryPickerProps) {
  const { colors } = useTheme();

  return (
    <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.container}>
      {categories.map((cat) => {
        const sel = cat.id === selectedId;
        return (
          <TouchableOpacity
            key={cat.id}
            activeOpacity={0.6}
            style={[styles.item, {
              backgroundColor: sel ? cat.color + '18' : colors.glass,
              borderColor: sel ? cat.color : colors.glassBorder,
              borderWidth: sel ? 1.5 : 0.5,
            }]}
            onPress={() => onSelect(cat)}
          >
            <View style={[styles.iconWrap, { backgroundColor: sel ? cat.color + '20' : cat.color + '12' }]}>
              <CategoryIcon name={cat.name} icon={cat.icon} size={22} color={sel ? cat.color : colors.textSecondary} />
            </View>
            <Text style={[styles.name, { color: sel ? cat.color : colors.glassTextSecondary }]}>{cat.name}</Text>
          </TouchableOpacity>
        );
      })}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { paddingHorizontal: 12, paddingVertical: 8, gap: 8 },
  item: { alignItems: 'center', justifyContent: 'center', paddingHorizontal: 12, paddingVertical: 10, borderRadius: 16, minWidth: 68 },
  iconWrap: { width: 36, height: 36, borderRadius: 12, alignItems: 'center', justifyContent: 'center', marginBottom: 4 },
  name: { fontSize: 10, fontWeight: '600', fontFamily: '-apple-system' },
});

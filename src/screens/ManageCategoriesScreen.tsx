import React, { useState, useCallback } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, TextInput, Alert } from 'react-native';
import Svg, { Path } from 'react-native-svg';
import { GlassView } from '../components/GlassView';
import { useTheme } from '../hooks/useTheme';
import { useCategories } from '../hooks/useCategories';
import { Category } from '../context/types';
import { ConfirmDialog } from '../components/ConfirmDialog';
import { useNavigation } from '@react-navigation/native';

const COLORS = ['#FF3B30','#FF9500','#FFCC00','#34C759','#00C7BE','#007AFF','#5856D6','#AF52DE','#FF2D55','#A2845E','#8E8E93','#636366','#1C1C1E','#0051D5','#2E7D32','#AD1457','#00695C','#283593','#4E342E','#37474F'];
const SUGGESTED_EMOJI = ['🛒','🚗','🏠','❤️','🎬','👕','📚','🍽','🧾','💰','💻','📈','⭐','🏋️','✈️','🎁','🐾','🔧'];

export function ManageCategoriesScreen() {
  const { colors } = useTheme();
  const navigation = useNavigation<any>();
  const { categories, addCategory, updateCategory, deleteCategory } = useCategories();

  const [editingId, setEditingId] = useState<number | null>(null);
  const [name, setName] = useState('');
  const [emoji, setEmoji] = useState('');
  const [color, setColor] = useState('#007AFF');
  const [type, setType] = useState<'income' | 'expense'>('expense');
  const [deleteId, setDeleteId] = useState<number | null>(null);

  const startEdit = useCallback((cat: Category) => {
    setEditingId(cat.id); setName(cat.name); setEmoji(cat.icon || '');
    setColor(cat.color); setType(cat.type);
  }, []);

  const handleSave = useCallback(async () => {
    if (!name.trim()) { Alert.alert('Errore', 'Inserisci un nome per la categoria.'); return; }
    if (editingId) {
      await updateCategory({ id: editingId, name: name.trim(), icon: emoji.trim() || '🏷', color, type, is_default: 0 });
    } else {
      await addCategory({ name: name.trim(), icon: emoji.trim() || '🏷', color, type, is_default: 0 });
    }
    setEditingId(null); setName(''); setEmoji(''); setColor('#007AFF'); setType('expense');
  }, [editingId, name, emoji, color, type, addCategory, updateCategory]);

  const handleDelete = useCallback(async () => {
    if (deleteId !== null) { await deleteCategory(deleteId); setDeleteId(null); }
  }, [deleteId, deleteCategory]);

  const handleCancel = useCallback(() => {
    setEditingId(null); setName(''); setEmoji(''); setColor('#007AFF'); setType('expense');
  }, []);

  return (
    <View style={[styles.container, { backgroundColor: 'transparent' }]}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
          <Svg width={22} height={22} viewBox="0 0 24 24" fill="none">
            <Path d="M15 18l-6-6 6-6" stroke={colors.text} strokeWidth={2.2} strokeLinecap="round" strokeLinejoin="round" />
          </Svg>
        </TouchableOpacity>
        <Text style={[styles.title, { color: colors.text }]}>Categorie</Text>
        <View style={{ width: 36 }} />
      </View>

      <ScrollView style={styles.scroll} showsVerticalScrollIndicator={false}>
        {/* Add/Edit Form */}
        <GlassView intensity="regular" style={styles.form} borderRadius={20}>
          <Text style={[styles.formTitle, { color: colors.glassText }]}>
            {editingId ? 'Modifica Categoria' : 'Nuova Categoria'}
          </Text>

          <View style={styles.nameEmojiRow}>
            <View style={styles.emojiInputWrap}>
              <TextInput
                style={[styles.emojiInput, { color: colors.text, borderColor: colors.glassBorder, backgroundColor: colors.inputBg }]}
                value={emoji} onChangeText={setEmoji} placeholder="🏷"
                placeholderTextColor={colors.textTertiary} maxLength={4}
              />
            </View>
            <TextInput
              style={[styles.nameInput, { color: colors.text, borderColor: colors.glassBorder, backgroundColor: colors.inputBg }]}
              value={name} onChangeText={setName} placeholder="Nome categoria"
              placeholderTextColor={colors.textTertiary}
            />
          </View>

          <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.emojiSuggestions}>
            {SUGGESTED_EMOJI.map((e) => (
              <TouchableOpacity key={e} style={[styles.emojiChip, { backgroundColor: colors.inputBg, borderColor: colors.glassBorder }]} onPress={() => setEmoji(e)}>
                <Text style={styles.emojiChipText}>{e}</Text>
              </TouchableOpacity>
            ))}
          </ScrollView>

          <View style={styles.typeRow}>
            <TouchableOpacity
              style={[styles.typeBtn, { backgroundColor: type === 'expense' ? colors.expenseSoft : colors.glass, borderColor: type === 'expense' ? colors.expense + '40' : colors.glassBorder }]}
              onPress={() => setType('expense')}
            >
              <Text style={{ color: type === 'expense' ? colors.expense : colors.textSecondary, fontWeight: '700', fontSize: 13 }}>Uscita</Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[styles.typeBtn, { backgroundColor: type === 'income' ? colors.incomeSoft : colors.glass, borderColor: type === 'income' ? colors.income + '40' : colors.glassBorder }]}
              onPress={() => setType('income')}
            >
              <Text style={{ color: type === 'income' ? colors.income : colors.textSecondary, fontWeight: '700', fontSize: 13 }}>Entrata</Text>
            </TouchableOpacity>
          </View>

          <Text style={[styles.label, { color: colors.glassTextSecondary }]}>Colore</Text>
          <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.colorRow}>
            {COLORS.map((c) => (
              <TouchableOpacity
                key={c}
                style={[styles.colorDot, { backgroundColor: c, borderWidth: color === c ? 3 : 0, borderColor: color === c ? colors.text : 'transparent' }]}
                onPress={() => setColor(c)}
              />
            ))}
          </ScrollView>

          <View style={styles.actions}>
            {(editingId || name || emoji) && (
              <TouchableOpacity style={[styles.actionBtn, { backgroundColor: colors.glass, borderColor: colors.glassBorder }]} onPress={handleCancel}>
                <Text style={{ color: colors.textSecondary, fontWeight: '600' }}>Annulla</Text>
              </TouchableOpacity>
            )}
            <TouchableOpacity style={[styles.actionBtn, { backgroundColor: colors.primary }]} onPress={handleSave}>
              <Text style={{ color: '#fff', fontWeight: '700' }}>{editingId ? 'Aggiorna' : 'Aggiungi'}</Text>
            </TouchableOpacity>
          </View>
        </GlassView>

        {/* Category List */}
        <Text style={[styles.listTitle, { color: colors.text }]}>Esistenti ({categories.length})</Text>
        {categories.map((cat) => (
          <GlassView key={cat.id} intensity="regular" style={styles.catItem} borderRadius={14}>
            <View style={styles.catLeft}>
              <View style={[styles.catIcon, { backgroundColor: cat.color + '18' }]}>
                {cat.icon ? <Text style={styles.catEmoji}>{cat.icon}</Text> : <Text style={[styles.catInitial, { color: cat.color }]}>{cat.name.charAt(0)}</Text>}
              </View>
              <View>
                <Text style={[styles.catName, { color: colors.glassText }]}>{cat.name}</Text>
                <Text style={[styles.catType, { color: colors.glassTextTertiary }]}>{cat.type === 'income' ? 'Entrata' : 'Uscita'}</Text>
              </View>
            </View>
            <View style={styles.catActions}>
              <TouchableOpacity onPress={() => startEdit(cat)} style={styles.catBtn}>
                <Svg width={16} height={16} viewBox="0 0 24 24" fill="none">
                  <Path d="M4 20h4L18.5 9.5a2.12 2.12 0 00-3-3L4 17v3z" stroke={colors.primary} strokeWidth={1.8} strokeLinecap="round" strokeLinejoin="round" />
                  <Path d="M13.5 6.5l3 3" stroke={colors.primary} strokeWidth={1.8} strokeLinecap="round" />
                </Svg>
              </TouchableOpacity>
              <TouchableOpacity onPress={() => setDeleteId(cat.id)} style={styles.catBtn}>
                <Svg width={16} height={16} viewBox="0 0 24 24" fill="none">
                  <Path d="M4 7h16M10 11v6M14 11v6M5 7l1 12a2 2 0 002 2h8a2 2 0 002-2l1-12M9 7V4a1 1 0 011-1h4a1 1 0 011 1v3" stroke={colors.expense} strokeWidth={1.8} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
              </TouchableOpacity>
            </View>
          </GlassView>
        ))}

        <View style={{ height: 140 }} />
      </ScrollView>

      <ConfirmDialog
        visible={deleteId !== null} title="Elimina categoria"
        message="Sei sicuro di voler eliminare questa categoria?"
        confirmText="Elimina" cancelText="Annulla"
        onConfirm={handleDelete} onCancel={() => setDeleteId(null)} danger
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingHorizontal: 16, paddingTop: 52, paddingBottom: 8 },
  backBtn: { width: 36, height: 36, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  title: { fontSize: 17, fontWeight: '700', fontFamily: '-apple-system', letterSpacing: -0.2 },
  scroll: { flex: 1, padding: 16 },
  form: { padding: 18, marginBottom: 20 },
  formTitle: { fontSize: 16, fontWeight: '700', fontFamily: '-apple-system', marginBottom: 14, letterSpacing: -0.1 },
  nameEmojiRow: { flexDirection: 'row', gap: 8, marginBottom: 10 },
  emojiInputWrap: { width: 56 },
  emojiInput: { borderWidth: 0.5, borderRadius: 12, paddingHorizontal: 8, paddingVertical: 10, fontSize: 22, textAlign: 'center' },
  nameInput: { flex: 1, borderWidth: 0.5, borderRadius: 12, paddingHorizontal: 12, paddingVertical: 10, fontSize: 15 },
  emojiSuggestions: { marginBottom: 12 },
  emojiChip: { paddingHorizontal: 10, paddingVertical: 6, borderRadius: 10, borderWidth: 0.5, marginRight: 6 },
  emojiChipText: { fontSize: 20 },
  typeRow: { flexDirection: 'row', gap: 8, marginBottom: 14 },
  typeBtn: { flex: 1, paddingVertical: 10, borderRadius: 12, borderWidth: 0.5, alignItems: 'center' },
  label: { fontSize: 11, fontWeight: '600', fontFamily: '-apple-system', marginBottom: 6, textTransform: 'uppercase', letterSpacing: 0.5 },
  colorRow: { marginBottom: 14 },
  colorDot: { width: 32, height: 32, borderRadius: 16, marginRight: 8 },
  actions: { flexDirection: 'row', gap: 8 },
  actionBtn: { flex: 1, paddingVertical: 12, borderRadius: 14, alignItems: 'center', borderWidth: 0 },
  listTitle: { fontSize: 13, fontWeight: '700', fontFamily: '-apple-system', marginBottom: 8, textTransform: 'uppercase', letterSpacing: 0.5 },
  catItem: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', padding: 12, marginBottom: 6 },
  catLeft: { flexDirection: 'row', alignItems: 'center', gap: 10 },
  catIcon: { width: 36, height: 36, borderRadius: 10, alignItems: 'center', justifyContent: 'center' },
  catEmoji: { fontSize: 18 },
  catInitial: { fontSize: 14, fontWeight: '700', fontFamily: '-apple-system' },
  catName: { fontSize: 14, fontWeight: '600', fontFamily: '-apple-system' },
  catType: { fontSize: 11, fontFamily: '-apple-system' },
  catActions: { flexDirection: 'row', gap: 8 },
  catBtn: { padding: 4 },
});

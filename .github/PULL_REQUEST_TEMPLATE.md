## 📋 Descripción del Cambio

> Reemplaza este texto con una descripción clara de los cambios realizados

### 🎯 Problema Resuelto

> ¿Qué problema o feature se está abordando?

### 💡 Solución Implementada

> Explicar cómo se resolvió el problema

### 📝 Cambios Clave

- [ ] Cambio 1
- [ ] Cambio 2
- [ ] Cambio 3

---

## 🔍 Checklist de Revisión

### Código

- [ ] Tests agregados/actualizados
- [ ] No hay N+1 queries en cambios de modelos
- [ ] Autorización validada con Pundit (si aplica)
- [ ] Código pasa `rubocop -a`
- [ ] Brakeman sin warnings críticos
- [ ] Gemfile.lock actualizado (si hay cambios en Gemfile)

### Base de Datos

- [ ] Migraciones son reversibles
- [ ] `db/schema.rb` actualizado
- [ ] Seeds actualizados (si aplica)
- [ ] Documentado comportamiento multitenancy (si aplica)

### Seguridad

- [ ] ✅ Sin credenciales hardcodeadas
- [ ] ✅ Todas las entradas validadas
- [ ] ✅ Sin logs de PII (emails sin anonimizar, etc)
- [ ] ✅ Autorización explícita en controllers
- [ ] ✅ No escalation de privilegios

### Documentación

- [ ] README actualizado (si aplica)
- [ ] MULTITENANCY.md actualizado (si aplica)
- [ ] Código comentado para lógica compleja
- [ ] Commit messages descriptivos

---

## 🧪 Testing

```bash
# Ejecutar tests locales
rails test

# Multitenancy (si aplica)
APARTMENT_TENANTS="public,acme" rails test

# Rubocop linting
rubocop -a

# Security audit
brakeman
bundler-audit
```

---

## 📸 Screenshots (si aplica)

> Agregar screenshots o GIFs de cambios visuales si es relevante

---

## 🚀 Deployment Notes

> Notas especiales para deployment en producción (migraciones, secrets, etc)

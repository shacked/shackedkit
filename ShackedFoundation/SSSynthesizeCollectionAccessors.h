#define SSSynthesizeOrderedCollectionAccessors(lowercasePropertyName, uppercasePropertyName)                                      \
    - (NSUInteger)countOf##uppercasePropertyName                                                                                  \
    {                                                                                                                             \
        return [_##lowercasePropertyName count];                                                                                  \
    }                                                                                                                             \
                                                                                                                                  \
    - (id)objectIn##uppercasePropertyName##AtIndex: (NSUInteger)index                                                             \
    {                                                                                                                             \
        return [_##lowercasePropertyName objectAtIndex: index];                                                                   \
    }                                                                                                                             \
                                                                                                                                  \
    - (id)lowercasePropertyName##AtIndexes: (NSIndexSet *)indexes                                                               \
    {                                                                                                                             \
        return [_##lowercasePropertyName objectsAtIndexes: indexes];                                                              \
    }                                                                                                                             \
                                                                                                                                  \
    - (void)get##uppercasePropertyName: (id __unsafe_unretained [])outObjects range: (NSRange)range                               \
    {                                                                                                                             \
        return [_##lowercasePropertyName getObjects: outObjects range: range];                                                    \
    }                                                                                                                             \
                                                                                                                                  \
    - (void)insertObject: (id)object in##uppercasePropertyName##AtIndex: (NSUInteger)index                                        \
    {                                                                                                                             \
        [_##lowercasePropertyName insertObject: object atIndex: index];                                                           \
    }                                                                                                                             \
                                                                                                                                  \
    - (void)insert##uppercasePropertyName: (NSArray *)objects atIndexes: (NSIndexSet *)indexes                                    \
    {                                                                                                                             \
        [_##lowercasePropertyName insertObjects: objects atIndexes: indexes];                                                     \
    }                                                                                                                             \
                                                                                                                                  \
    - (void)removeObjectFro_##lowercasePropertyName##AtIndex: (NSUInteger)index                                                   \
    {                                                                                                                             \
        [_##lowercasePropertyName removeObjectAtIndex: index];                                                                    \
    }                                                                                                                             \
                                                                                                                                  \
    - (void)remove##uppercasePropertyName##AtIndexes: (NSIndexSet *)indexes                                                       \
    {                                                                                                                             \
        [_##lowercasePropertyName removeObjectsAtIndexes: indexes];                                                               \
    }                                                                                                                             \
                                                                                                                                  \
    - (void)replaceObjectIn##uppercasePropertyName##AtIndex: (NSUInteger)index withObject: (id)object                             \
    {                                                                                                                             \
        [_##lowercasePropertyName replaceObjectAtIndex: index withObject: object];                                                \
    }                                                                                                                             \
                                                                                                                                  \
    - (void)replace##uppercasePropertyName##AtIndexes: (NSIndexSet *)indexes with##uppercasePropertyName: (NSArray *)objects      \
    {                                                                                                                             \
        [_##lowercasePropertyName replaceObjectsAtIndexes: indexes withObjects: objects];                                         \
    }

#define SSSynthesizeUnorderedCollectionAccessors(lowercasePropertyName, uppercasePropertyName)      \
    - (NSUInteger)countOf##uppercasePropertyName                                                    \
    {                                                                                               \
        return [_##lowercasePropertyName count];                                                    \
    }                                                                                               \
                                                                                                    \
    - (NSEnumerator *)enumeratorOf##uppercasePropertyName                                           \
    {                                                                                               \
        return [_##lowercasePropertyName objectEnumerator];                                         \
    }                                                                                               \
                                                                                                    \
    - (id)memberOf##uppercasePropertyName: (id)object                                               \
    {                                                                                               \
        return [_##lowercasePropertyName member: object];                                           \
    }                                                                                               \
                                                                                                    \
    - (void)add##uppercasePropertyName##Object: (id)object                                          \
    {                                                                                               \
        [_##lowercasePropertyName addObject: object];                                               \
    }                                                                                               \
                                                                                                    \
    - (void)add##uppercasePropertyName: (NSSet *)set                                                \
    {                                                                                               \
        [_##lowercasePropertyName unionSet: set];                                                   \
    }                                                                                               \
                                                                                                    \
    - (void)remove##uppercasePropertyName##Object: (id)object                                       \
    {                                                                                               \
        [_##lowercasePropertyName removeObject: object];                                            \
    }                                                                                               \
                                                                                                    \
    - (void)remove##uppercasePropertyName: (NSSet *)set                                             \
    {                                                                                               \
        [_##lowercasePropertyName minusSet: set];                                                   \
    }                                                                                               \
                                                                                                    \
    - (void)intersect##uppercasePropertyName: (NSSet *)set                                          \
    {                                                                                               \
        [_##lowercasePropertyName intersectSet: set];                                               \
    }
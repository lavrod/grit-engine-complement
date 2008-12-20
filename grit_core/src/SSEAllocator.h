template <class T> class SSEAllocator {

    public:

        typedef T                 value_type;
        typedef value_type*       pointer;
        typedef const value_type* const_pointer;
        typedef value_type&       reference;
        typedef const value_type& const_reference;
        typedef std::size_t       size_type;
        typedef std::ptrdiff_t    difference_type;


        SSEAllocator (void) {}

        SSEAllocator (const SSEAllocator&) {}

        ~SSEAllocator (void) {}

        template <class U>
        SSEAllocator (const SSEAllocator<U>&) {}

        template <class U>
        struct rebind { typedef SSEAllocator<U> other; };


        pointer address(reference x) const { return &x; }

        const_pointer address(const_reference x) const { return &x; }


        pointer allocate (size_type n, const_pointer = 0)
        {
                size_type size = n * sizeof(T);
                //std::cout << "+size: " << size << std::endl;
                // offset by positive amount to force alignment
                // store the offset behind the pointer to the aligned block
                unsigned char *block = (unsigned char*)std::malloc(size+1+15);
                if (!block)
                        throw std::bad_alloc();
                //std::cout << "+block: " << (void*)block << std::endl;
                unsigned char *aligned16 =
                      (unsigned char*)((size_t)(block+1+15)&(size_t)0xFFFFFFF0);
                //std::cout << "+aligned16: " << (void*)aligned16 << std::endl;
                unsigned char offset = aligned16 - block;
                aligned16[-1] = offset;
                return (pointer)aligned16;
        }

        void deallocate (pointer p, size_type)
        {
                unsigned char *aligned16 = (unsigned char*) p;
                //std::cout << "-aligned16: " << (void*)aligned16 << std::endl;
                unsigned char offset = aligned16[-1];
                unsigned char *block = aligned16 - offset;
                //std::cout << "-block: " << (void*)block << std::endl;
                std::free(block);
        }


        size_type max_size (void) const
        {
                return static_cast<size_type>(-1) / sizeof(value_type);
        }


        void construct (pointer p, const value_type& x) { new(p)value_type(x); }

        void destroy (pointer p) { p->~value_type(); }


    private:

        void operator = (const SSEAllocator&);

};

template<> class SSEAllocator<void> {
        typedef void value_type;
        typedef void *pointer;
        typedef const void *const_pointer;

        template <class U>
        struct rebind { typedef SSEAllocator<U> other; };
};


template <class T>
inline bool operator == (const SSEAllocator<T>&, const SSEAllocator<T>&)
{ return true; }

template <class T>
inline bool operator != (const SSEAllocator<T>&, const SSEAllocator<T>&)
{ return false; }


// vim: shiftwidth=8:tabstop=8:expandtab

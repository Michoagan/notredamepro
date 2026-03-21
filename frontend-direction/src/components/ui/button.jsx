import * as React from "react"

const Button = React.forwardRef(({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? "span" : "button"
    return (
        <Comp
            className={`inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none ring-offset-background ${className || 'bg-slate-900 text-white hover:bg-slate-800 h-10 py-2 px-4'}`}
            ref={ref}
            {...props}
        />
    )
})
Button.displayName = "Button"

export { Button }
